---
title: "Elixir Pattern Matching in a nut shell"
date: 2021-06-29
tags: ["elixir", "elixir-beginning"]
author: Dung Nguyen
image: "/img/pattern-matching.png"
draft: false
---


If you are new to Elixir, Pattern Matching may be something strange to you. When you get familiar with it, you will know how powerful it is. And I'm sure that you will definite love it. Pattern matching is used everywhere in your elixlir code . And I would bring it to other language that I use ( if I can :D)

But it's not so hard. 

## What does Pattern Matching do?

Give you a variable/value, you might want

1. Check if data type is match your expected data type
2. Check if structure of data match your expected data structure
3. Assign matching part of data to a variable

And pattern matching do all these thing for you. Just look at some example. 

When you try these example, it will raise exception if data doesn't match against the pattern. In real Elixir app, you won't use it this way, check **Where it is used** at the end of this article

## Pattern matching with Map/Struct

**1. Check if this data is a map**

```elixir
%{} = params
```

**2. Check if data is a map and has key `email` and email value is `zoo@example.com`**

```elixir
%{"email" => "zoo@example.com"} = params
```

**3. Check if data is a map and has key `email`, if matchs pattern, assign value of key `email` to variable `my_email`**

```elixir
%{"email" => my_email} = params
```

**4. Check if data is a map and has key `email`, I don't want to extract value**

use `_` to ignore value

```elixir
%{"email" => _} = params
```

**5. Pattern matching nested map**

```elixir
%{"address" => %{"city" => city}} = params
```

**6. Check if data is type struct `User`**

```elixir
%User{} = params
```

> The rest is same with map. Struct is basically a map with atom key.

## Pattern matching with List

**1. Check if data is empty lis**

```elixir
[] = params
```

**2. Check if data is a list and not empty**

```elixir
[_|_] = params
```

**3. Check if data is exact list**

```elixir
[1, 2] = params
```

**4. Check if data is list and extract first element and remaining**

```elixir
[first_element | remaining] = params
```

## Pattern matching with Tuple

You don't have much pattern to match against tuple

**1. Check if data is tuple of 2 elements**

```elixir
{_, _} = params
```

**2. Check if data is tuple and has specific value**

```elixir
{:ok, data} = result
# you use this most of time
```

## Where to use pattern matching

**1. case clause**

```elixir
case user do
	%User{is_active: true} -> "Log you in"
	%User{is_active: false} -> "Check your email"
	_others -> "Not a user"
end
```

**2. with clause**

```elixir
with {:ok, user} <- create_user(params) do
	# your code
end
```

**3. function**

```elixir
def is_admin(%User{role: "admin"}), do: true
def is_admin(%User{role: _}), do: false
def is_admin(_), do: raise "Not a user"
```

## Conclusion

At first, it's a bit strange to grasp, but gradually you can live without it. It is one of Elixir's features that I love most. And I think you will. Using it more and its power is in your hand.
