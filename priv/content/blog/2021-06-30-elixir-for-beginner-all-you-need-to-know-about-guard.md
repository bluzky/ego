---
title: "Elixir for Beginner - All you need to know about guard"
date: 2021-06-30
tags: ["elixir", "elixir-beginner"]
author: Dung Nguyen
image: "/img/elixir-guard.webp"
draft: false
---

## What is Guard in Elixir

In previous post, I explain what is Pattern Matching and how to use it.

[Elixir pattern matching in a nutshell](https://dev.to/bluzky/elixir-pattern-matching-in-a-nutshell-5fef)

Pattern matching is so cool but some time I want to do some more complicated checking. With pattern matching I can easily do this

```elixir
def can_access?(%User{paid_user: true}), do: true
```

Yes, Pattern matching can do check value with exact value easily. But for example, I want to allow `user with level > 25` to access.

How to do that check with Pattern matching?

Pattern matching as it's named, it is used to match data against pattern. If you want to do more complex check, you need another guy. That is where `guard` shines, it is complement for Pattern Matching



```elixir
def can_access?(%User{level: level}) when level > 25, do: true
```



## What is `guard`

- Guard is a complement to your pattern matching to do more complex check.

- Guard expression is invoke after pattern mattching

- In many cases, `Guard` and `Pattern matching` can produce the same result, so use which you like.



```elixir
# sum on empty list
# pattern matching
def sum_list([] = _input), do: 0

# guard
def sum_list(input) when input == [], do: 0
```



**Some example**

- Check primitive type

  ```elixir
  def sum(a, b) when is_integer(a) and is_integer(b) do
  	a + b
  end
  ```

- Check value is nil/ not nil

  ```elixir
  def string_length(string) when not is_nil(string) do
  	# your code
  end
  ```

- Check if input  in a list of allowed values

  ```elixir
  def can_edit?(%User{role: role}) when role in ["admin", "moderator"] do
  	true
  end
  ```

- And many more ...




## Where to use guard?

Where you can use Pattern Matching, you can use Guard

- `case` block

  ```elixir
  case value do
  	x when is_binary(x) -> String.to_integer(x)
  	x when is_integer(x) -> x
  	_ -> raise "Invalid value"
  end
  ```

  

- `with` block

  ```elixir
  with user when not is_nil(user) <- find_user(id) do
  	# your code block
  end
  ```

  

- `function` clause as our example above



## Why my guard not work?

Not all expression will work with guard. Only a list of built-in `guard` and combination of them work in guard expression.

Check this from https://hexdocs.pm/elixir/guards.html#list-of-allowed-expressions

> - comparison operators ([`==`](https://hexdocs.pm/elixir/Kernel.html#==/2), [`!=`](https://hexdocs.pm/elixir/Kernel.html#!=/2), [`===`](https://hexdocs.pm/elixir/Kernel.html#===/2), [`!==`](https://hexdocs.pm/elixir/Kernel.html#!==/2), [`>`](https://hexdocs.pm/elixir/Kernel.html#%3E/2), [`>=`](https://hexdocs.pm/elixir/Kernel.html#%3E=/2), [`<`](https://hexdocs.pm/elixir/Kernel.html#%3C/2), [`<=`](https://hexdocs.pm/elixir/Kernel.html#%3C=/2))
> - strictly boolean operators ([`and`](https://hexdocs.pm/elixir/Kernel.html#and/2), [`or`](https://hexdocs.pm/elixir/Kernel.html#or/2), [`not`](https://hexdocs.pm/elixir/Kernel.html#not/1)). Note [`&&`](https://hexdocs.pm/elixir/Kernel.html#&&/2), [`||`](https://hexdocs.pm/elixir/Kernel.html#%7C%7C/2), and [`!`](https://hexdocs.pm/elixir/Kernel.html#!/1) sibling operators are **not allowed** as they're not *strictly* boolean - meaning they don't require arguments to be booleans
> - arithmetic unary and binary operators ([`+`](https://hexdocs.pm/elixir/Kernel.html#+/1), [`-`](https://hexdocs.pm/elixir/Kernel.html#-/1), [`+`](https://hexdocs.pm/elixir/Kernel.html#+/2), [`-`](https://hexdocs.pm/elixir/Kernel.html#-/2), [`*`](https://hexdocs.pm/elixir/Kernel.html#*/2), [`/`](https://hexdocs.pm/elixir/Kernel.html#//2))
> - [`in`](https://hexdocs.pm/elixir/Kernel.html#in/2) and [`not in`](https://hexdocs.pm/elixir/Kernel.html#in/2) operators (as long as the right-hand side is a list or a range)
> - "type-check" functions ([`is_list/1`](https://hexdocs.pm/elixir/Kernel.html#is_list/1), [`is_number/1`](https://hexdocs.pm/elixir/Kernel.html#is_number/1), etc.)
> - functions that work on built-in datatypes ([`abs/1`](https://hexdocs.pm/elixir/Kernel.html#abs/1), [`map_size/1`](https://hexdocs.pm/elixir/Kernel.html#map_size/1), etc.)



## Can I define my own guard?

Yes you can define a guard with  [`defguard/1`](https://hexdocs.pm/elixir/Kernel.html#defguard/1) and [`defguardp/1`](https://hexdocs.pm/elixir/Kernel.html#defguardp/1) . But you should only define your own guard if you have a **really really reasonable reason** to do so.

In my experience, I have never defined a guard my own, built-in guards are too enough.



## Conclustion

With Pattern matching and Guard, you have a super powerful combo in your hand. Let's code!
