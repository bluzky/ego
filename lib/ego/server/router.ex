defmodule Ego.Server.Router do
  use Ego.Server, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Ego.Server.BuildContext)
  end

  scope "/", Ego.Server do
    pipe_through(:browser)

    get("/categories", CategoryController, :index)
    get("/categories/page/:page", CategoryController, :index)
    get("/categories/:slug", CategoryController, :show)
    get("/categories/:slug/page/:page", CategoryController, :show)

    get("/tags", TagController, :index)
    get("/tags/page/:page", TagController, :index)
    get("/tags/:slug", TagController, :show)
    get("/tags/:slug/page/:page", TagController, :show)

    get("/", PageController, :index)
    get("/page/:page", PageController, :index)
    get("/*path", PageController, :show)
  end
end
