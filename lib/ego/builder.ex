defmodule Ego.Builder do
  alias Ego.Store
  alias Ego.Renderer
  alias Ego.FileSystem
  alias Ego.Context

  def build(assigns) do
    context = Context.new(%{assigns: assigns})

    Enum.each(Store.all_types(), fn type ->
      context
      |> Context.put_section(type)
      |> build_content()
    end)

    Enum.each(Store.all_terms(), fn {type, terms} ->
      context = Context.put_section(context, type)
      build_term(context, terms)
    end)

    copy_assets()
  end

  def build_content(%{section: :page} = context) do
    render_page(context, "index")
    # do not re build index page
    Store.filter(%{type: :page})
    |> Enum.reject(&(&1.slug == "index"))
    |> Enum.map(fn document ->
      context
      |> Context.put_output_path(FileSystem.output_path(context.section, document.slug))
      |> generate_file([document.layout, "single"], document: document)
    end)
  end

  defp render_page(context, "index") do
    document =
      Store.find(%{
        type: :page,
        slug: "index"
      })

    context
    |> Context.put_output_path(FileSystem.output_path(context.section, "index"))
    |> generate_file("index", document: document)
  end

  def build_content(context) do
    documents = Store.filter(%{type: context.section})

    context
    |> Context.put_output_path(FileSystem.output_path(context.section, "index"))
    |> generate_file("list", documents: documents)

    Enum.map(documents, fn document ->
      context
      |> Context.put_output_path(FileSystem.output_path(context.section, document.slug))
      |> generate_file([document.layout, "single"], document: document)
    end)
  end

  defp build_term(context, terms) do
    context
    |> Context.put_output_path(FileSystem.output_path(context.section, "index"))
    |> generate_file(["terms", "list"], terms: terms)

    Enum.each(terms, fn term ->
      documents = Store.by_term(context.section, term.title)

      context
      |> Context.put_output_path(FileSystem.output_path(context.section, term.slug))
      |> generate_file(["term", "single"], term: term, documents: documents)
    end)
  end

  defp generate_file(context, template, assigns) do
    html = Renderer.render(context, template, assigns)
    FileSystem.write_file(context.output_path, html)
  end

  defp copy_assets() do
    Ego.FileSystem.copy_all(
      FileSystem.source_path(["assets/", "static/"]),
      FileSystem.output_path("")
    )
  end
end
