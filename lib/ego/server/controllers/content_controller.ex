defmodule Ego.Server.ContentController do
  use Ego.Server, :controller
  alias Ego.{Context, Store, Renderer}

  # render terms
  def index(conn, %{"type" => type} = params) when type in ["tags", "categories"] do
    terms =
      Ego.Store.all_terms()
      |> Map.get(type, [])

    context =
      Context.new(section: String.to_existing_atom(type))
      |> Context.put_var(:terms, terms)
      |> Context.put_template(["terms", "list"])

    render_index(conn, params, context)
  end

  # render archetype
  def index(conn, %{"type" => type} = params) do
    documents = Ego.Store.by_type(type)

    if documents != [] do
      context =
        Context.new(section: String.to_existing_atom(type))
        |> Context.put_var(:documents, documents)
        |> Context.put_template("list")

      render_index(conn, params, context)
    else
      Ego.Server.PageController.show(conn, %{"slug" => type})
    end
  end

  defp render_index(conn, params, context) do
    content = Renderer.render(context, context.template)
    html(conn, content)
  end

  def show(conn, %{"type" => type, "slug" => slug}) when type in ["tags", "categories"] do
    term =
      Store.all_terms()
      |> Map.get(type, [])
      |> Enum.find(&(&1.slug == slug))

    if term do
      documents = Store.by_term(term.type, term.title)

      content =
        Context.new(section: String.to_existing_atom(type))
        |> Renderer.render(["term", "single"], documents: documents, term: term)

      html(conn, content)
    else
      text(conn, "404 not found")
    end
  end

  def show(conn, %{"type" => type, "slug" => slug}) do
    document = Ego.Store.find(%{type: type, slug: slug})

    if document do
      content =
        Context.new(section: String.to_existing_atom(type))
        |> Renderer.render(
          [document.layout, "single"],
          document: document
        )

      html(conn, content)
    else
      text(conn, "404 not found")
    end
  end
end
