defmodule Ego.Server.ContentController do
  use Ego.Server, :controller

  # render terms
  def index(conn, %{"type" => type} = params) when type in ["tags", "categories"] do
    term_type =
      case type do
        "tags" -> "tag"
        "categories" -> "category"
      end

    terms =
      Ego.DocumentStore.all_terms()
      |> Map.get(type, [])

    assigns =
      build_assigns(%{
        "terms" => terms
      })

    render_index(
      conn,
      %{params | "type" => term_type},
      ["terms", "list"],
      build_assigns(%{"terms" => terms})
    )
  end

  # render archetype
  def index(conn, %{"type" => type} = params) do
    documents = Ego.DocumentStore.filter(%{"type" => type})

    if documents != [] do
      render_index(conn, params, "list", build_assigns(%{"documents" => documents}))
    else
      Ego.Server.PageController.show(conn, %{"slug" => type})
    end
  end

  defp render_index(conn, params, template, assigns) do
    content = Ego.Renderer.render(template, assigns, type: params["type"])
    html(conn, content)
  end

  def show(conn, %{"type" => type, "slug" => slug}) when type in ["tags", "categories"] do
    term_type =
      case type do
        "tags" -> "tag"
        "categories" -> "category"
      end

    term =
      Ego.DocumentStore.all_terms()
      |> Map.get(type, [])
      |> Enum.find(&(&1["slug"] == slug))

    if term do
      documents = Ego.DocumentStore.by_term(term_type, term["title"])

      content =
        Ego.Renderer.render(
          ["term", "single"],
          build_assigns(%{"documents" => documents, "term" => term}),
          type: type
        )

      html(conn, content)
    else
      text(conn, "404 not found")
    end
  end

  def show(conn, %{"type" => type, "slug" => slug}) do
    document = Ego.DocumentStore.find(%{"type" => type, "slug" => slug})

    if document do
      content =
        Ego.Renderer.render(
          [document["layout"], "single"],
          build_assigns(%{"document" => document}),
          type: type
        )

      html(conn, content)
    else
      text(conn, "404 not found")
    end
  end
end
