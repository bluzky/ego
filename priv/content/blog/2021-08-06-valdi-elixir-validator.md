---
title: "Easy data validation with with Valdi in Elixir"
date: 2021-08-06
tags: ["elixir", "validation"]
author: Dung Nguyen
image: "/img/valdi-data-validator.webp"
draft: false
---

> Credit: this icon is from [flaticon.com](https://www.flaticon.com/free-icon/parking-barrier_2983600)

In previous article, I shown you how to implement you own validation module. I you haven't read it, you can find it here [How to build an Elixir validator from scratch ](/blog/2021-07-31-build-elixir-validator-from-scratch)

And I think some of you may want a ready to use library so I wrapped it up, added some useful api and published on [hex.pm](https://hex.pm/packages/valdi) and [github repo here](https://github.com/bluzky/valdi).

This post is just showcases of what it can do. (not too much fancy)
First, add dependencies to your `mix.exs` and you are ready to go.

```elixir
{:valdi, "~> 0.2.0"}
```

And this is how it works.

**Validate using a specific validation function**

```elixir
iex(1)> age = 20
20
iex(2)> Valdi.validate_number(age, min: 18, max: 60)
:ok
```

But most of the time you don't do this, you will want to combine multiple validations at a time.

```elixir
iex(4)> Valdi.validate("20", type: :integer,  number: [min: 18, max: 60])
{:error, "is not a integer"}
```

And you may want to validate a list of value too:

```elixir
iex(1)> Valdi.validate_list(["hi", "how", "are", "you", 100], type: :string,  length: [min: 3])
{:error,
 [[0, "length must be greater than or equal to 3"], [4, "is not a string"]]}
```
If validation failed, you got a list of error and index of error item.


`Valdi` supports you to validate a simple map with given specification:

```elixir
product_spec = %{
    name: [type: :string, required: true],
    sku: [type: :string, required: true],
    price: [type: :integer, number: [min: 0]]
}
Valdi.validate_map(%{
    name: "A magic pen",
    sku: nil,
    price: -1
}, product_spec)

# {:error, %{price: "must be greater than or equal to 0", sku: "is required"}}
```

**Valdi does not support nested map validation**.

You might want to take a look at [Contrak](https://github.com/bluzky/contrak), it extended `Valdi` by providing a simple way to define and validate nested schema.

Why I didn't put those in just one library? I think data validation and schema validation are quite different, so I want to keep libraries simple and do its best thing.


**Here you can define your own validation**

```elixir
Valdi.validate("as008x8234", type: :string, func: fn value ->
   if String.match?(value, ~r/^\d{4}$/), do: :ok, else: {:error, "not a year string"}
end)

# {:error, "not a year string"}
```

Hope this small library can help. If you have any suggestion please comment.
Thank you.
