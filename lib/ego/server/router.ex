defmodule Ego.Server.Router do
  use Ego.Server, :router
  require Ego.Server.RuntimeStatic

  pipeline :browser do
    plug(Ego.Server.RuntimeStatic)
    plug(:accepts, ["html"])
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
