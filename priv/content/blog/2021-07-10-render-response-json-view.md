---
title: "Elixir phoenix - Render Ecto schema to json with relationships"
date: 2021-07-10
tags: ["elixir", "phoenix", "json view", "ecto"]
author: Dung Nguyen
image: "/img/json-view.png"
draft: false
---

When writing API with Phoenix and render json to client,
- **For some fields I want to keep it original value.**
- **For some fields, I want to do some calculation or format data before returning.**
- **And I want to render Ecto association too.**

An while working on an project at [OnPoint](https://www.onpoint.vn/) I have build a little module that helps to do this easier.

I have extract that module and release as a package named `JsonView`. Its source code is hosted on github:

https://github.com/bluzky/json_view

You can use it with Phoenix.View or use it independently. It helps to manipulate data, and handle rendering association automatically.

**I have published an article on how to write it**
[A better way to render json response in Elixir Phoenix](https://dev.to/bluzky/a-better-way-to-render-json-response-in-elixir-phoenix-41a3)

Let's take a look.

First define view modules

```elixir
  defmodule MyApp.UserView do
      use JsonView
      def render("user.json", %{user: user}) do
      	render_json(user, [:first_name, :last_name, :vatar], [], [])
      end
  end
      
  defmodule MyApp.PostView do
      use JsonView

      # define which fields return without modifying
      @fields [:title, :content, :excerpt, :cover]
      # define which fields that need to format or calculate, you have to define `render_field/2` below
      @custom_fields [:like_count]
      # define which view used to render relationship
      @relationships [author: MyApp.UserView]

      def render("post.json", %{post: post}) do
          # 1st way if `use JsonView`
          render_json(post, @fields, @custom_fields, @relationships)
      end

      def render_field(:like_count, item) do
          # load like_count from some where
      end
  end
```

And then use it

```elixir
post = %Post{
	title: "Hello JsonView",
	excerpt: "Now you can render Json easier",
	content: "Install and put it to work",
	cover: nil,
	inserted_at: ~N[2021-07-05 00:00:00],
	updated_at: ~N[2021-07-09 00:00:00],
	author: %User{
		first_name: "Daniel",
		last_name: "James",
		email: "daniel@example.com",
		avatar: nil,
		inserted_at: ~N[2021-06-30 00:00:00]
		updated_at: ~N[2021-07-02 00:00:00]
	}
}

MyApp.PostView.render("post.json", %{post: post})

# or invoke from PostController
render(conn, "post.json", post: post)
```



This is the result that you can use to return from PhoenixController

```elixir
%{
	title: "Hello JsonView",
	excerpt: "Now you can render Json easier",
	content: "Install and put it to work",
	cover: nil,
  like_count: nil,
	author: %{
		first_name: "Daniel",
		last_name: "James"
	}
}
```

If you have any feedback, please comment or [create an issue](https://github.com/bluzky/json_view/issues/new).

In the next post I will go through step by step to write this library.
