defmodule Ego.Builder do
  alias Ego.Store
  alias Ego.Renderer
  alias Ego.FileSystem
  alias Ego.Context

  require Logger

  def build(assigns) do
    context = Context.new(%{assigns: assigns})

    Enum.each(Store.all_types(), fn type ->
      context
      |> Context.put_type(type)
      |> build_content()
    end)

    Enum.each(Store.list_taxonomies(), fn {type, terms} ->
      context = Context.put_type(context, type)
      build_term(context, terms)
    end)

    copy_assets()
  end

  def build_content(%{type: :page} = context) do
    document = Store.find(%{type: :page, slug: "index"})

    context
    |> Renderer.render_index(document)
    |> write_file(FileSystem.output_file(:page, nil))

    # do not re build index page
    Store.filter(%{type: :page})
    |> Enum.reject(&(&1.slug == "index"))
    |> Enum.map(fn document ->
      context
      |> Renderer.render_page(document)
      |> write_file(FileSystem.output_file(:page, document.slug))
    end)
  end

  def build_content(context) do
    documents = Store.filter(%{type: context.type})

    context
    |> Renderer.render_content_index(documents)
    |> write_file(FileSystem.output_file(context.type, nil))

    Enum.map(documents, fn document ->
      context
      |> Renderer.render_content_page(document)
      |> write_file(FileSystem.output_file(document.type, document.slug))
    end)
  end

  defp build_term(context, terms) do
    context
    |> Renderer.render_term_index(terms)
    |> write_file(FileSystem.output_file(context.type, nil))

    Enum.each(terms, fn term ->
      documents = Store.by_term(context.type, term.title)

      context
      |> Renderer.render_term_page(term, documents: documents)
      |> write_file(FileSystem.output_file(context.type, term.slug))
    end)
  end

  defp write_file({:ok, content, _context}, file) do
    FileSystem.write_file(file, content)
  end

  defp write_file({:error, message}, file) do
    Logger.error("Cannot render file #{file} due to error #{inspect(message)}")
  end

  defp copy_assets() do
    Ego.FileSystem.copy_all(
      FileSystem.source_path(["assets/", "static/"]),
      FileSystem.output_path("")
    )
  end
end
