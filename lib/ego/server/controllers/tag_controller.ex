defmodule Ego.Server.TagController do
  use Ego.Server, :controller
  alias Ego.{Context, Store, Renderer}
  action_fallback(Ego.Server.FallbackController)

  # render terms
  def index(conn, params) do
    terms = Store.list_taxonomies() |> Map.get(:tags, [])

    if terms != [] do
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

      Renderer.render_term_index(context, terms)
    else
      text(conn, "404 not found")
    end
  end

  def show(conn, %{"slug" => slug} = params) do
    term =
      Store.list_taxonomies()
      |> Map.get(:tags, [])
      |> Enum.find(&(&1.slug == slug))

    if term do
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

      Renderer.render_term_page(context, term)
    else
      text(conn, "404 not found")
    end
  end
end
