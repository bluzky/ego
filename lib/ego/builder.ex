defmodule Ego.Builder do
  alias Ego.Document
  alias Ego.Renderer
  alias Ego.FileSystem

  def build(assigns) do
    build("page", assigns)
    build("blog", assigns)
  end

  def build("page", assigns) do
    render_page("index", assigns)
    # do not re build index page
    get_in(assigns, ["site", "documents"])
    |> Document.filter(%{"type" => "page"})
    |> Enum.reject(&(&1["slug"] == "index"))
    |> Enum.map(&render_page(&1, assigns))
  end

  defp render_page("index", assigns) do
    document =
      Document.find(get_in(assigns, ["site", "documents"]), %{"type" => "page", "slug" => "index"})

    html =
      Renderer.render(
        "index",
        FileSystem.lookup_dir("page"),
        Map.put(assigns, :document, document)
      )

    FileSystem.write_file(FileSystem.output_path("page", "index"), html)
  end

  defp render_page(document, assigns) do
    assigns = Map.put(assigns, "document", document)
    html = Renderer.render([document["layout"], "single"], FileSystem.lookup_dir("page"), assigns)
    FileSystem.write_file(FileSystem.output_path("page", document["slug"]), html)
  end

  def build("category", assigns) do
  end

  def build("tag", assigns) do
  end

  def build(archetype, assigns) do
    documents =
      get_in(assigns, ["site", "documents"])
      |> Document.filter(%{"type" => archetype})

    render_list(archetype, documents, assigns)
    Enum.map(documents, &render_single(archetype, &1, assigns))
  end

  def render_list(type, documents, assigns) do
    assigns = Map.put(assigns, "documents", documents)
    html = Renderer.render("list", FileSystem.lookup_dir(type), assigns)
    FileSystem.write_file(FileSystem.output_path(type, "index"), html)
  end

  def render_single(type, document, assigns) do
    assigns = Map.put(assigns, "document", document)
    html = Renderer.render([document["layout"], "single"], FileSystem.lookup_dir(type), assigns)
    FileSystem.write_file(FileSystem.output_path(type, document["slug"]), html)
  end
end
