---
title: "JWT alternative token Authentication with Phoenix.Token"
date: 2021-08-26
tags: ["elixir", "phoenix", "authentication"]
categories: ["elixir", "phoenix"]
author: Dung Nguyen
image: "/img/jwt-phoenix.png"
draft: false
---

In this post, you'll learn how to implement JWT-based authentication using `Phoenix.Token`.

In our previous projects, we use `guardian` library to implement JWT authentication. `Guardian` is a great library which provides lots of method and tool to work with authentication. But sometime we don't need them all. And recently, I found `Phoenix.Token` module shipped with `phoenix` framework that helps me to implement JWT alternative token authentication with few lines of code.

Let's do it.

## 1. Implement Token module

Here is the document of [Phoenix.Token](https://hexdocs.pm/phoenix/Phoenix.Token.html).

We just wrap `sign` and `verify` function from `Phoenix.Token` to create and check for valid token.

```elixir
defmodule MyApp.Token do
  @signing_salt "octosell_api"
  # token for 2 week
  @token_age_secs 14 * 86_400

  @doc """
  Create token for given data
  """
  @spec sign(map()) :: binary()
  def sign(data) do
    Phoenix.Token.sign(MyAppWeb.Endpoint, @signing_salt, data)
  end


  @doc """
  Verify given token by:
  - Verify token signature
  - Verify expiration time
  """
  @spec verify(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify(token) do
    case Phoenix.Token.verify(MyAppWeb.Endpoint, @signing_salt, token,
             max_age: @token_age_secs
           ) do
      {:ok, data} -> {:ok, data}
      _error -> {:error, :unauthenticated}
    end
  end
end
```

Here we wrap in `Token` module to simplify API. We pass `MyAppWeb.Endpoint` here to use secret key that config for endpoint. You can pass secret key from config as firt argument.


## 2. Generate token


```elixir
defmodule MyAppWeb.SessionController do
  ...
  def new(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Account.authenticate_user(email, password),
         {:ok, token} <- MyApp.Token.sign(%{user_id: user.id}) do
      ...
      # return token to client
    else
      _ ->
        {:error, gettext("email or password is in correct")}
    end
  end
end

```

Here we create Phoenix token with a map `%{user_id: user.id}` and return to client.

## 3. Build Plug to verify token

Client sent token to server via header `Authorization`. We extract token and call `Token.verify` to check if token is valid and not expired.

```elixir
defmodule MyApp.Plug.Authenticate do
  import Plug.Conn
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- MyApp.Token.verify(token) do
      conn
      |> assign(:current_user, MyApp.Account.get_user(data.user_id))
    else
      error ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.put_view(MyAppWeb.ErrorView)
        |> Phoenix.Controller.render(:"401")
        |> halt()
    end
  end
end
```

## 4. Add plug to router

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug MyAppWeb.Plug.Authenticate
  end

  scope "/api", MyAppWeb do
    pipe_through :api
    post "/auth/login", SessionController, :new
  end

  scope "/api", MyAppWeb do
    pipe_through [:api, :authenticated]
    delete "/auth/logout", SessionController, :delete
    ...
  end
end

```

We have done with it. Just a few line of code

## Conclusion

Implement token authentication with `Phoenix` is so easy and you may not need Guardian for your application.
In this post I only implement simple version of token authentication. In real application, you should store token signature in database or redis and
- In `Authenticate` plug check if the token exists in database.
- When user logout, clear it from database/redis to make sure that token cannot be used to make request anymore.

Thanks for reading.
