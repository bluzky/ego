---
title: "How to build an Elixir validator from scratch"
date: 2021-07-31
tags: ["elixir", "validation"]
author: Dung Nguyen
image: "/img/build-json-validator.webp"
draft: false
---


Validation is a must have part of web application. You have to validate request parameter before processing, you validate data before inserting to database, and many more.

Normally, I use `Ecto.Changeset` to do validation job. But it comes with changeset, I have to build schema, changeset then do the validation. Sometime you just don't need too much thing like that.

So today we are going to build a simple validation module to use without changeset, or in some project you don't use `Ecto`, or just for learning.

## What our validation module includes:

- Type validation
- Number validation
- Length validation for `map, list, string`
- String format validation using regex
- Inclusion, exclusion validations

That's is quite enough, you can define more if you want.
And the module will support a simple API to validate a value

```elixir
validate(value::any(), validations::keyword()) :: :ok | {:error, String.t()}
```

Let's start.

## Type validation

Let's call our module `Checky`. Type check is quite straight forward. Elixir support most of type check guard that we need:

```elixir
defmodule Checky do
  def validate_type(value, :boolean) when is_boolean(value), do: :ok
  def validate_type(value, :integer) when is_integer(value), do: :ok
  def validate_type(value, :float) when is_float(value), do: :ok
  def validate_type(value, :number) when is_number(value), do: :ok
  def validate_type(value, :string) when is_binary(value), do: :ok
  def validate_type(value, :binary) when is_binary(value), do: :ok
  def validate_type(value, :tuple) when is_tuple(value), do: :ok
  def validate_type(value, :array) when is_list(value), do: :ok
  def validate_type(value, :list) when is_list(value), do: :ok
  def validate_type(value, :atom) when is_atom(value), do: :ok
  def validate_type(value, :function) when is_function(value), do: :ok
  def validate_type(value, :map) when is_map(value), do: :ok
  # we will add some more validation here
  def validate_type(_, type), do: {:error, "is not a #{type}"}
end
```

Easy, right? Now let's support checking for `struct`:

```elixir
defmodule Checky do

  ...
  # from Elixir 1.12 you can do this
  def validate_type(value, struct_name) when is_struct(value, struct_name), do: :ok
  # this is for Elixir before 1.12
  def validate_type(%{__struct__: struct}, struct_name) when struct == struct_name, do: :ok
  ...
end
```

- Here we check for `keyword`

```elixir
defmodule Checky do
  ...
  # empty list is also a empty keyword
  def validate_type([] = _check_item, :keyword), do: :ok
  # if list item is a tuple of 2 and first element is atom then it is a keyword list
  def validate_type(items, :keyword) when is_list(items) do
    valid? = Enum.all(item, fn 
        {key, _} when is_atom(key) -> true
        _ -> false 
    end)
    
    if valid? do
      :ok
    else
      {:error, "is not a keyword"}
    end
  end
  ...
end
```



- Now let support array check `{:array, type}` which is similar to `Ecto.Schema`.

```elixir
defmodule Checky do
  ...
  def validate_type(value, {:array, type}) when is_list(value) do
    # We will check type for each value in the list
    array(value, &validate_type(&1, type))
  end
  ...
   # loop and validate element in array using `validate_func`
  defp array(data, validate_func)

  defp array([], _) do
    :ok
  end

  # validate recursively, and return error if any vadation failed
  defp array([h | t], validate_func) do
    case validate_func.(h) do
      :ok ->
        array(t, validate_func)
      err ->
        err
    end
  end
end
```

Phew! We have done with type validation. You can add more type validation if you want.


## Format Validation

This validation is super easy, `Regex` do that for us:

```elixir
defmodule Checky end
  def validate_format(value, check) when is_binary(value) do
    if Regex.match?(check, value), do: :ok, else: {:error, "does not match format"}
  end

  def validate_format(_value, _check) do
    {:error, "format check only support string"}
  end
end
```

## Inclusion and exclusion validation
These are trivial checks too. Just make sure it is implement `Enumerable` protocol.

```elixir
defmodule Checky do
  def validate_inclusion(value, enum) do
    if Enumerable.impl_for(enum) do
      if Enum.member?(enum, value) do
        :ok
      else
        {:error, "not be in the inclusion list"}
      end
    else
      {:error, "given condition does not implement protocol Enumerable"}
    end
  end

  @doc """
  Check if value is **not** included in the given enumerable. Similar to `validate_inclusion/2`
  """
  def validate_exclusion(value, enum) do
    if Enumerable.impl_for(enum) do
      if Enum.member?(enum, value) do
        {:error, "must not be in the exclusion list"}
      else
        :ok
      end
    else
      {:error, "given condition does not implement protocol Enumerable"}
    end
  end
end
```

## Number validation

This is one of the most complicated part of our module. It's not difficult, it's just long.
We will support following checks:
  - `equal_to`
  - `greater_than_or_equal_to` | `min`
  - `greater_than`
  - `less_than`
  - `less_than_or_equal_to` | `max`

And it should support multiple check like this:
```elixir
 validate_number(x, [min: 10, max: 20])
```

First we code validation function for single condition like this

```elixir
  def validate_number(number, {:equal_to, check_value}) do
    if number == check_value do
      :ok
    else
      {:error, "must be equal to #{check_value}"}
    end
  end
```
As I said, it's so simple. You can fill the remaining check right? Or you can check the final code at the end of the post.
After implementing all validation fucntion for number, it's time to support multiple condtion check.

```elixir
  @spec validate_number(integer() | float(), keyword()) :: :ok | error
  def validate_number(value, checks) when is_list(checks) do
    if is_number(value) do
      checks
      |> Enum.reduce(:ok, fn
        check, :ok ->
          validate_number(value, check)

        _, error ->
          error
      end)
    else
      {:error, "must be a number"}
    end
  end
```

## Length validation

Length is just a number, so we can reuse number validation. We just have to check if given value is one of support types: `list`, `map`, `string`, and `tuple`

We will implement `get_length/1` function to get data length first.
```elixir
  @spec get_length(any) :: pos_integer() | {:error, :wrong_type}
  defp get_length(param) when is_list(param), do: length(param)
  defp get_length(param) when is_binary(param), do: String.length(param)
  defp get_length(param) when is_map(param), do: param |> Map.keys() |> get_length()
  defp get_length(param) when is_tuple(param), do: tuple_size(param)
  defp get_length(_param), do: {:error, :wrong_type}
```

Then we do number validation on the length value

```elixir
  @spec validate_length(support_length_types, keyword()) :: :ok | error
  def validate_length(value, checks) do
    with length when is_integer(length) <- get_length(value),
         # validation length number
         :ok <- validate_number(length, checks) do
      :ok
    else
      {:error, :wrong_type} ->
        {:error, "length check supports only lists, binaries, maps and tuples"}

      {:error, msg} ->
        # we prepend length to message return by validation number to get full message
        # like: "length must be equal to x"
        {:error, "length #{msg}"}
    end
  end
```

## Combine all validation

Most of time you want to use multiple valitions on the data. So we will add a function that do multiple validation

We define a simple structure for validation first. This is our validate function spec

```elixir
 @spec validate(any(), keyword()) :: :ok | {:error, messages}
```

Then we can use it like this:

```elixir
Checky.validate(value, type: :string, format: ~r/\d\d.+/, length: [min: 8, max: 20])
```

Validations is a keyword list with short name for validation:
- `:type` -> `validate_type`
- `:format` -> `validate_format`
- `:in` -> `validate_inclusion`
- `:not_in` -> `validate_exclusion`
- `:number` -> `validate_number`
- `:length` -> `validate_length`

**Define mapping function:**

```elixir
  defp get_validator(:type), do: &validate_type/2
  defp get_validator(:format), do: &validate_format/2
  defp get_validator(:number), do: &validate_number/2
  defp get_validator(:length), do: &validate_length/2
  defp get_validator(:in), do: &validate_inclusion/2
  defp get_validator(:not_in), do: &validate_exclusion/2
  defp get_validator(name), do: {:error, "validate_#{name} is not support"}

```

**Go checking validations one by one**

```elixir
  def validate(value, validators) do
    do_validate(value, validators, :ok)
  end

  defp do_validate(_, [], acc), do: acc

  # check validations one by one
  defp do_validate(value, [h | t] = _validators, acc) do
    case do_validate(value, h) do
      :ok -> do_validate(value, t, acc)
      error -> error
    end
  end

  # validate single validation
  defp do_validate(value, {validator, opts}) do
    case get_validator(validator) do
      {:error, _} = err -> err
      validate_func -> validate_func.(value, opts)
    end
  end
```

## Conclusion

Writing a validation module is not so hard. Now you can add more validations to fit your need. As I promised, this is the full source of the module with custom validation fucntion.
[https://github.com/bluzky/valdi/blob/main/lib/valdi.ex](https://github.com/bluzky/valdi/blob/main/lib/valdi.ex)

Thank you for reading to the end of this post. Please leave me a comment.
