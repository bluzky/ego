defmodule Ego.Renderer do
  alias Ego.FileSystem
  alias Ego.Document

  def render(assigns) do
    render("index", assigns)
    render("page", assigns)
    render("blog", assigns)
  end

  def render("index", assigns) do
    fs = FileSystem.new(lookup_dir("page"))

    document =
      Document.find(get_in(assigns, ["site", "documents"]), %{"type" => "page", "slug" => "index"})

    content =
      FileSystem.read_template_file("index", fs)
      |> Solid.parse!()
      |> Solid.render(Map.put(assigns, "document", document), file_system: {FileSystem, fs})
      |> to_string()

    FileSystem.reset(fs)

    html =
      FileSystem.read_template_file("baseof", fs)
      |> Solid.parse!()
      |> Solid.render(Map.put(assigns, "inner_content", content), file_system: {FileSystem, fs})
      |> to_string

    layout = FileSystem.reset(fs)
    write_file(output_path("page", "index"), html)
  end

  def render("page", assigns) do
    # do not re render index page
    get_in(assigns, ["site", "documents"])
    |> Document.filter(%{"type" => "page"})
    |> Enum.reject(&(&1["slug"] == "index"))
    |> Enum.map(&render_page(&1, assigns))
  end

  defp render_page(document, assigns) do
    fs = FileSystem.new(lookup_dir("page"))
    assigns = Map.put(assigns, "document", document)

    content =
      FileSystem.read_template_file([document["layout"], "single"], fs)
      |> Solid.parse!()
      |> Solid.render(assigns, file_system: {FileSystem, fs})
      |> to_string()

    FileSystem.reset(fs)

    html =
      FileSystem.read_template_file("baseof", fs)
      |> Solid.parse!()
      |> Solid.render(Map.put(assigns, "inner_content", content), file_system: {FileSystem, fs})
      |> to_string()

    layout = FileSystem.reset(fs)
    write_file(output_path("page", document["slug"]), html)
  end

  def render("category", assigns) do
  end

  def render("tag", assigns) do
  end

  def render(archetype, assigns) do
    documents =
      get_in(assigns, ["site", "documents"])
      |> Document.filter(%{"type" => archetype})

    render_list(archetype, documents, assigns)
    Enum.map(documents, &render_single(&1, assigns))
  end

  def render_list(type, documents, assigns) do
    fs = FileSystem.new(lookup_dir(type))
    assigns = Map.put(assigns, "documents", documents)

    content =
      FileSystem.read_template_file("list", fs)
      |> Solid.parse!()
      |> Solid.render(assigns, file_system: {FileSystem, fs})
      |> to_string()

    FileSystem.reset(fs)

    html =
      FileSystem.read_template_file("baseof", fs)
      |> Solid.parse!()
      |> Solid.render(Map.put(assigns, "inner_content", content), file_system: {FileSystem, fs})
      |> to_string()

    layout = FileSystem.reset(fs)
    write_file(output_path(type, "index"), html)
  end

  def render_single(document, assigns) do
    fs = FileSystem.new(lookup_dir(document["type"]))
    assigns = Map.put(assigns, "document", document)

    content =
      FileSystem.read_template_file([document["layout"], "single"], fs)
      |> Solid.parse!()
      |> Solid.render(assigns, file_system: {FileSystem, fs})
      |> to_string()

    FileSystem.reset(fs)

    html =
      FileSystem.read_template_file("baseof", fs)
      |> Solid.parse!()
      |> Solid.render(Map.put(assigns, "inner_content", content), file_system: {FileSystem, fs})
      |> to_string()

    layout = FileSystem.reset(fs)
    write_file(output_path(document["type"], document["slug"]), html)
  end

  defp lookup_dir("page") do
    [
      "layout/",
      "layout/_default"
    ]
  end

  defp lookup_dir(type) do
    [
      "layout/#{type}",
      "layout/_default"
    ]
  end

  @output_dir "public/"
  def output_path("page", slug) do
    Path.join(@output_dir, "#{slug}.html")
  end

  def output_path(type, slug) do
    Path.join(@output_dir, "#{type}/#{slug}.html")
  end

  def write_file(path, content) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content, [:write])
  end
end
