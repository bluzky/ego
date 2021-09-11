defmodule Ego.Builder do
  alias Ego.DocumentStore
  alias Ego.Renderer
  alias Ego.FileSystem

  def build(assigns) do
    Enum.each(DocumentStore.all_types(), &build(&1, assigns))

    Enum.each(DocumentStore.all_terms(), fn {type, terms} ->
      build_term(type, terms, assigns)
    end)

    copy_assets()
  end

  def build("page", assigns) do
    render_page("index", assigns)
    # do not re build index page
    get_in(assigns, ["site", "documents"])
    |> DocumentStore.filter(%{"type" => "page"})
    |> Enum.reject(&(&1["slug"] == "index"))
    |> Enum.map(&render_page(&1, assigns))
  end

  defp render_page("index", assigns) do
    document =
      DocumentStore.find(get_in(assigns, ["site", "documents"]), %{
        "type" => "page",
        "slug" => "index"
      })

    html =
      Renderer.render(
        "index",
        Map.put(assigns, :document, document),
        type: "page"
      )

    FileSystem.write_file(FileSystem.output_path("page", "index"), html)
  end

  defp render_page(document, assigns) do
    assigns = Map.put(assigns, "document", document)
    html = Renderer.render([document["layout"], "single"], assigns, type: "page")
    FileSystem.write_file(FileSystem.output_path("page", document["slug"]), html)
  end

  def build(archetype, assigns) do
    documents = DocumentStore.filter(%{"type" => archetype})
    render_list(archetype, documents, assigns)
    Enum.map(documents, &render_single(archetype, &1, assigns))
  end

  def render_list(type, documents, assigns) do
    assigns = Map.put(assigns, "documents", documents)
    html = Renderer.render("list", assigns, type: type)
    FileSystem.write_file(FileSystem.output_path(type, "index"), html)
  end

  def render_single(type, document, assigns) do
    assigns = Map.put(assigns, "document", document)
    html = Renderer.render([document["layout"], "single"], assigns, type: type)
    FileSystem.write_file(FileSystem.output_path(type, document["slug"]), html)
  end

  def build_term(type, terms, assigns) do
    build_list_term(type, terms, assigns)
    Enum.each(terms, &build_single_term(type, &1, assigns))
  end

  defp build_list_term(type, terms, assigns) do
    assigns = Map.put(assigns, "terms", terms)
    html = Renderer.render(["terms", "list"], assigns, type: type)
    FileSystem.write_file(FileSystem.output_path(type, "index"), html)
  end

  def build_single_term(type, term, assigns) do
    documents = DocumentStore.by_term(type, term["title"])
    assigns = Map.merge(assigns, %{"term" => term, "documents" => documents})
    html = Renderer.render(["term", "single"], assigns, type: type)

    term["type"]
    |> FileSystem.output_path(term["slug"])
    |> FileSystem.write_file(html)
  end

  defp copy_assets() do
    Ego.FileSystem.copy_all(
      FileSystem.source_path(["assets/", "static/"]),
      FileSystem.output_path("")
    )
  end
end
