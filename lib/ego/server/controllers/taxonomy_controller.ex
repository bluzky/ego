defmodule Ego.Server.TaxonomyController do
  use Ego.Server, :controller
  alias Ego.Renderer
  alias Ego.Store
  action_fallback(Ego.Server.FallbackController)

  # render terms
  def index(conn, params) do
    taxonomy = Store.list_taxonomies() |> Map.get(conn.assigns.type, [])

    if taxonomy do
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

      Renderer.render_taxonomy(context, taxonomy.page)
    else
      text(conn, "404 not found")
    end
  end

  def show(conn, %{"slug" => slug}) do
    document =
      Store.list_taxonomies()
      |> get_in([conn.assigns.type, :terms])
      |> Enum.find(&(&1.slug == slug))

    if document do
      Renderer.render_taxonomy(conn.assigns.context, document)
    else
      text(conn, "404 not found")
    end
  end
end
