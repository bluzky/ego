defmodule Ego.Server.PageController do
  use Ego.Server, :controller
  alias Ego.{Context, Store, Renderer}

  action_fallback(Ego.Server.FallbackController)

  def index(conn, _params) do
    document = Ego.Store.find(%{type: :page, slug: "index"})
    Renderer.render_index(conn.assigns.context, document)
  end

  def show(conn, %{"slug" => slug}) do
    document = Ego.Store.find(%{type: :page, slug: slug})

    if document do
      Renderer.render_page(conn.assigns.context, document)
    else
      text(conn, "404 not found")
    end
  end
end
