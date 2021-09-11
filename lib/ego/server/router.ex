defmodule Ego.Server.Router do
  use Ego.Server, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/", Ego.Server do
    get("/:type/:slug", ContentController, :show)
    get("/:type", ContentController, :index)
    get("/:type/page/:page", ContentController, :index)
    get("/", PageController, :index)
    get("/page/:page", PageController, :index)
    get("/:slug", PageController, :show)
  end
end