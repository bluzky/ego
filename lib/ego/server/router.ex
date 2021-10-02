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

    get("/categories", TaxonomyController, :index, assigns: %{type: :categories})
    get("/categories/page/:page", TaxonomyController, :index, assigns: %{type: :categories})
    get("/categories/:slug", TaxonomyController, :show, assigns: %{type: :categories})
    get("/categories/:slug/page/:page", TaxonomyController, :show, assigns: %{type: :categories})

    get("/tags", TaxonomyController, :index, assigns: %{type: :tags})
    get("/tags/page/:page", TaxonomyController, :index, assigns: %{type: :tags})
    get("/tags/:slug", TaxonomyController, :show, assigns: %{type: :tags})
    get("/tags/:slug/page/:page", TaxonomyController, :show, assigns: %{type: :tags})

    get("/", PageController, :index)
    get("/page/:page", PageController, :index)
    get("/*path", PageController, :show)
  end
end
