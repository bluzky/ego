---
title: "How to validate request params in Phoenix"
date: 2021-08-14
tags: ["elixir", "phoenix", "param validation"]
author: Dung Nguyen
image: "/img/validate-request-params.png"
draft: false
---

> Credit: filter image taken from [svgrepo.com](https://www.svgrepo.com/svg/231531/filter)

In web developments, server receives lots of request data from client side. And when working with request params from client, my first rule is:

> Don't believe the client


Imagine that you provide API to list all post using the filter from client, and user may add `user_id` which point to other user, and you don't remove that unexpected field from request params. If you don't handle your logic carefully, you may accidentally leak data.


So every request should be cleaned from unexpected params,  casted to the proper data type, and validated before passing to business layer.

You can achieve this by:



## Using Ecto

If you are building a web server using Phoenix, I guess `Ecto` is already in your dependencies. Just use it.

Thank to Ecto schemaless, you can build changeset from a dynamic schema:

```elixir
defmodule MyApp.PostController do
    ...
    defp index_params(params) do
        default = %{
      status: nil,
      q: nil,
      is_published: true
    }

    types = %{
      status: :string,
      q: :string,
      is_published: :boolean
    }

    changeset =
      {default, types}
      |> Ecto.Changeset.cast(params, Map.keys(types))
    
    if changeset.valid? do
        {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
        {:error, changeset}
    end
    end
    
    def index(conn, params) do
        with {:ok, valid_params} <- index_params(params) do
            # do your logic
        end
    end
    ...
end
```


With Ecto you can do validation on your params as you do with your schema changeset.

This way is simple and most of you are familiar with it. But you have to write much code and cannot cast and validate nested params.


## Use library `Tarams`

This library provide a simple way to define schema. Let's rewrite example above using `tarams`.

First add this to your dependency list:

```
{:tarams, "~> 1.0.0"}
```

```elixir
defmodule MyApp.PostController do
    ...
    @index_params %{
        status: :string,
        q: :string
        is_published: [type: :boolean, default: true],
        page: [type: :integer, number: [min: 1]],
        size: [type: :integer, number: [min: 10, max: 100]]
    }
    def index(conn, params) do
        with {:ok, valid_params} <- Tarams.cast(params, @index_params) do
            # do your logic
        end
    end
    ...
end
```



And it support nested params too

```elixir
defmodule MyApp.PostController do
    ...
    @create_params %{
        title: [type: :string, required: true],
        content: [type: :string, required: true],
        tags: [type: {:array, :string}],
        published_at: :naive_datetime,
        meta: %{
            tile: :string,
            description: :string,
            image: :string
        }
    }
    def create(conn, params) do
        with {:ok, valid_params} <- Tarams.cast(params, @create_params) do
            MyApp.Content.create_post(valid_params)
        end
    end
    ...
end
```


## Conclusion

All request params should be casted and validated at controller. Then you only work with data that you know what it is, and you don't have to worry about unexpected parameters.

Thanks for reading, hope it can helps.
