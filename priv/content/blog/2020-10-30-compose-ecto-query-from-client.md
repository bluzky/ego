---
title: "Compose Ecto Query From Client"
date: 2020-10-30
tags: ["elixir", "phoenix", "query", "ecto", "querie"]
author: Dung Nguyen
draft: false
image: "/img/request-to-query.png"
---
## The story
At our company, [OnPoint](https://www.onpoint.vn/), we are building an ecommerce website using Phoenix Framework. And I am working on admin to manage product, orders ... All the listing pages need a filter and this filter change frequently, operation team wants to add this field, order by that field. And each time they change their requirements I have to update query code.

My team use Django Admin before, they support an easy way to compose query directly from the URL. You don't have to change code on the back-end. It'll be great if I can do it with Phoenix. 

What it should have:
- Support basic query operator: `>, >=, <, <=, =, !=, like, ilike, in`
- Query join table
- Can sort result 

This is the result after some night of work:

[https://github.com/bluzky/querie](https://github.com/bluzky/querie)

## How it work
- I define a simple rule for passing parameter from client side. The key must follow format `[column]__[operator]=[value]`.
- On the server side, it is parsed to `{operator, {column, value}}` with appropriate data type
- Then it is passed to a filter function to build Ecto query dynamically

You can try with [example project](https://github.com/bluzky/querie/tree/main/example) to see how it works.

## How to use it

### 1. Define a filter schema
For example you have a Post schema:
```elixir
defmodule Example.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset

  def state_enum(), do: ~w(draft published archived trash)

  schema "posts" do
    field(:content, :string)
    field(:state, :string, default: "draft")
    field(:title, :string)
    field(:view_count, :integer, default: 0)
    belongs_to(:category, Example.PostMeta.Category)
    belongs_to(:author, Example.Account.User)
  end
end
```

And you want to filter the Post by title, state, view_count. This is the filter schema:
```elixir
@schema %{
    title: :string,
    state: :string, # short form
    view_count: [type: :integer] # long form
}
```

### 2. Parse request parameters and build the query

Use `Querie.parse/2` to parse request parameters with your schema

```elixir
alias Example.Content.Post

def index(conn, params) do
    with {:ok, filter} <- Querie.parse(@schema, params) do
	 query = Querie.filter(Post, filter)
	 # Or you can pass a query like this
	 # query = from(p in Post, where: ....)
	 # query = Querie.filter(query, filter)
	 posts = Repo.all(query)
	 # do the rendering here
    else
    {:error, errors} ->
	 IO.puts(inspect(errors)
	 # or do anything with error
	 # error is a list of tuple {field, message}
    end
end
```

### 3. Compose URL
Then from client side you can send a form:

```html
<form action="/posts">
    <label>Titlte</label>
    <input type="text" name="title__icontains">
    <label>State</label>
    <select name="state">
        <option value="draft"></option>
        <option value="published"></option>
        <option value="trashed"></option>
    </select>
    <label>View count greater than</label>
    <input type="number" name="view_count__ge">
</form>
```

Or directly from URL with data like this:
```
http://localhost:4000/posts?title__icontains=elixir&state=published&view_count__ge=100
```

Enter and see the result

## Query joined table

It quite simple to filter result with filter on joined tables.

### 1. Update your query
Querie support `ref` operator to join tables.
For example you want to query Post by author whose email contains sam the query would be:

```
?author__ref[email__icontains]=sam
```

### 2. Update your schema

```elixir
alias Example.Account.User

@schema %{
    title: :string,
    state: :string,
    view_count: [type: :integer],
    author: [
		type: :ref, # this references to another schema
		model: User, # which schema to query
		schema: %{ # define filter schema for User
			email: :string
		}
	  ]
}
```

For more query options, please read [document](https://github.com/bluzky/querie)

If you have any suggestion, please leave a comment or [open an issuse](https://github.com/bluzky/querie/issues/new) on Github.

Thanks for reading.


