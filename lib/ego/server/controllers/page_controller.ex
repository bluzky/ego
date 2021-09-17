defmodule Ego.Server.PageController do
  use Ego.Server, :controller
  alias Ego.{Context, Store, Renderer}

  action_fallback(Ego.Server.FallbackController)

  def index(conn, params) do
    document = Ego.Store.find(%{type: :page, slug: "index"})

    context =
      if params["page"] do
        Ego.Context.put_var(
          conn.assigns.context,
          :__current_page,
          String.to_integer(params["page"])
        )
      else
        conn.assigns.context
      end

    Renderer.render_index(context, document)
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
