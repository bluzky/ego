---
title: "Encrypt your database with Ecto custom type"
date: 2021-08-20
tags: ["elixir", "ecto", "crypto"]
author: Dung Nguyen
image: "/img/encrypt-data-ecto.png"
draft: false
---

If your data is encrypted, even if it's leaked, no one know what is the data. That's great.

In this post, I'm going to show you how to encrypt data with Ecto. `Ecto` allows developer to define their own types. And we will define a type called `EncryptedText` which encrypts data before persiting to database and decrypts data after loading.

## 1. Define encrypt/decrypt methods

This is a simple version of crypto module:

```elixir
defmodule Crypto do
  @block_size 16

  def generate_secret do
    :crypto.strong_rand_bytes(@block_size)
    |> Base.encode64()
  end

  def encrypt(plaintext, secret_key) do
    with {:ok, secret_key} <- decode_key(secret_key) do
      iv = :crypto.strong_rand_bytes(@block_size)
      plaintext = pad(plaintext, @block_size)
      ciphertext = :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, plaintext, true)

      {:ok, Base.encode64(iv <> ciphertext)}
    end
  end

  def decrypt(ciphertext, secret_key) do
    with {:ok, secret_key} <- decode_key(secret_key),
         {:ok, <<iv::binary-@block_size, ciphertext::binary>>} <- Base.decode64(ciphertext) do
      plaintext =
        :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, ciphertext, false)
        |> unpad

      {:ok, plaintext}
    else
      {:error, _} = err -> err
      _ -> {:error, "Bad encrypted data"}
    end
  end

  defp pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<to_add>>, to_add)
  end

  defp unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end
end
```

Let go through the code

```elixir
  def generate_secret do
    :crypto.strong_rand_bytes(@block_size)
    |> Base.encode64()
  end
```
This function generate a 16 bytes secret key and encode base 64 string so you can add it to config.

- `encrypt/2` function

```elixir
 def encrypt(plaintext, secret_key) do
    # check the key size
    with {:ok, secret_key} <- decode_key(secret_key) do
      
      # random initial vector
      iv = :crypto.strong_rand_bytes(@block_size)
      # if length of text is not multiple of @block_size
      # we add more data until it meets condition
      plaintext = pad(plaintext, @block_size)
      # encrypt here
      ciphertext = :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, plaintext, true)

      {:ok, Base.encode64(iv <> ciphertext)}
    end
  end
```

This is the most important line
```elixir
ciphertext = :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, plaintext, true)
```
- `iv` is initial vector. AES-128 algorithms encrypts data by block of 16 bytes, so we need initial vector to make sure that the output of blocks with same data are different from each other.
- The last parameter is set to `true` to encrypt, set to `false` to decrypt data

And then we encode output to base 64 string. Here we concatenate `iv` and `ciphertext` so that we can extract `iv` to use for decrypting
```elixir
{:ok, Base.encode64(iv <> ciphertext)}
```

- `decrypt/2` function

```elixir
def decrypt(ciphertext, secret_key) do
    # check the key
    with {:ok, secret_key} <- decode_key(secret_key),
         {:ok, <<iv::binary-@block_size, ciphertext::binary>>} <- Base.decode64(ciphertext) do
      plaintext =
        :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, ciphertext, false)
        |> unpad

      {:ok, plaintext}
    else
      {:error, _} = err -> err
      _ -> {:error, "Bad encrypted data"}
    end
  end
```

We extract `iv` and encrypted data from input
```elixir
{:ok, <<iv::binary-@block_size, ciphertext::binary>>} <- Base.decode64(ciphertext)
```

We use pattern matching to extract first 16 byte and assign to `iv` and assign remaining data to `ciphertext`. Then decrypting data

```elixir
plaintext =
    :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, ciphertext, false)
    |> unpad
```

This line is similar to the line which encrypts data, the difference is here we replace `plaintext` by `ciphertext` and last parameter is set to `false`. After data is decrypted, we need to remove padding to get the original data.


## 2. Build `EncryptedText` type

I define a type to store binary data, you can define a `EncryptedMap` to store map data. The most important function are `dump` and `load` where we encrypt before persisting and decrypt after loading.


```elixir
defmodule EncryptedText do
  use Ecto.Type

  # we store data as string
  def type, do: :string

  def cast(value) when is_binary(value) do
    {:ok, value}
  end
  def cast(_), do: :error

  def dump(nil), do: nil
  # encrypt data before persist to database
  def dump(data) when is_binary(data) do
    with {:ok, secret_key} <- Application.fetch_env(:myapp, :ecto_secret_key),
         {:ok, data} <- Crypto.encrypt(data, secret_key) do
      {:ok, data}
    else
      _ -> :error
    end
  end

  def dump(_), do: :error

  def load(nil), do: nil
  # decrypt data after loaded from database
  def load(data) when is_binary(data) do
    secret_key = Application.fetch_env!(:myapp, :ecto_secret_key)
    case Crypto.decrypt(data, secret_key) do
      {:error, _} -> :error
      ok -> ok
    end
  end

  def load(_), do: :error

  def embed_as(_), do: :dump
end

```


## 3. Use it in your schema

- You must add secret key to your app config first.

```elixir
config :myapp, :ecto_secret_key, "your key using Crypto.generate_secret"
```

- Add to schema

```elixir
schema "users" do
    field :name, :string
    ...
    field :secret, EncryptedText
    ...
end
```

Your data are safe now.


## 4. Conclusion

With Crypto you can implement encrypted field for any type of data you want.

There is an issue when you want to change your secret key, you have to load your data row by row, decrypt and then encrypt with new key and update to database.

I found this article which explains very well about crypto if you are interested [https://www.thegreatcodeadventure.com/elixir-encryption-with-erlang-crypto/](https://www.thegreatcodeadventure.com/elixir-encryption-with-erlang-crypto/)
Although she uses old crypto API so it will throw some warnings.

I implemented encrypted type for text and map for my company project here if you want to use it: 

[Github](https://github.com/onpointvn/magik/tree/main/lib/ecto_type)

Thanks for reading.
