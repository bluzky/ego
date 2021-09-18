defmodule Ego.Server.ContentController do
  use Ego.Server, :controller
  alias Ego.{Context, Store, Renderer}
  action_fallback(Ego.Server.FallbackController)

  # render terms
  def index(conn, %{"type" => type} = params) when type in ["tags", "categories"] do
    type = String.to_existing_atom(type)

    terms =
      Store.list_taxonomies()
      |> Map.get(type, [])

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

    context
    |> Context.put_type(type)
    |> Renderer.render_term_index(terms)
  end

  # render archetype
  def index(conn, %{"type" => type}) do
    documents = Store.by_type(type)

    if documents != [] do
      conn.assigns.context
      |> Context.put_type(String.to_existing_atom(type))
      |> Renderer.render_content_index(documents)
    else
      Ego.Server.PageController.show(conn, %{"slug" => type})
    end
  end

  def show(conn, %{"type" => type, "slug" => slug}) when type in ["tags", "categories"] do
    term =
      Store.list_taxonomies()
      |> Map.get(String.to_existing_atom(type), [])
      |> Enum.find(&(&1.slug == slug))

    if term do
      documents = Store.by_term(term.type, term.title)

      conn.assigns.context
      |> Context.put_var(:documents, documents)
      |> Renderer.render_term_page(term)
    else
      text(conn, "404 not found")
    end
  end

  def show(conn, %{"type" => type, "slug" => slug}) do
    document =
      Store.by_type(type)
      |> Store.find(%{slug: slug})

    if document do
      Renderer.render_content_page(conn.assigns.context, document)
    else
      text(conn, "404 not found")
    end
  end
end
