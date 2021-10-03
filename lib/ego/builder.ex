defmodule Ego.Builder do
  alias Ego.Store
  alias Ego.Renderer
  alias Ego.FileSystem
  alias Ego.Context

  require Logger

  def build() do
    context = build_context()
    clean_build_dir()
    build_pages(context)

    Enum.each(Store.list_taxonomies(), fn {type, taxonomy} ->
      context = Context.put_type(context, type)
      build_taxonomy(context, taxonomy)
    end)

    copy_assets()
  end

  defp build_context() do
    site =
      Application.get_env(:ego, :site_config, %{})
      |> Map.put(:documents, Store.list_documents() |> Enum.reject(& &1.list_page))
      |> Map.put(:document_tree, Store.get_document_tree())
      |> Map.put(:taxonomies, Store.list_taxonomies())

    Ego.Context.new(%{assigns: %{site: site}})
  end

  defp clean_build_dir() do
    File.rm_rf!(FileSystem.output_path(""))
  end

  # Build all page from store
  defp build_pages(context) do
    Ego.Store.list_documents()
    |> Enum.map(fn document ->
      build_page(context, document)
    end)
  end

  # Build a single page with given context
  # if context return pagination, render until there is no more page
  def build_page(context, document) do
    context
    |> Renderer.render_page(document)
    |> tap(&write_file/1)
    |> handle_paginate(fn page ->
      context
      |> Context.put_var("__current_page", page)
      |> build_page(document)
    end)
  end

  # generate static page for term: category, tag
  defp build_taxonomy(context, taxonomy) do
    documents = [taxonomy.page | taxonomy.terms]

    Enum.each(documents, fn document ->
      build_single_term(context, document)
    end)
  end

  # generate single term page
  # we pass document which match term with context
  defp build_single_term(context, term) do
    context
    |> Renderer.render_taxonomy(term)
    |> tap(&write_file/1)
    |> handle_paginate(fn page ->
      context
      |> Context.put_var("__current_page", page)
      |> build_single_term(term)
    end)
  end

  # this function looking for `__next_page` in the render context
  # if it's not nil, invoke `paginate_build_func/1` with page number
  defp handle_paginate({:ok, _, %{vars: %{"__next_page" => page}}}, paginate_build_func) do
    if is_integer(page) and page > 0 do
      paginate_build_func.(page)
    end
  end

  defp handle_paginate(_, _), do: nil

  # write rendered content to file if render successful
  defp write_file({:ok, content, %{vars: vars}}) do
    vars["current_path"]
    |> FileSystem.output_file()
    |> FileSystem.write_file(content)
  end

  defp write_file({:error, message, %{vars: vars}}) do
    Logger.error("Cannot render file #{vars["current_path"]} due to error #{inspect(message)}")
  end

  # copy assets from directory `assets/` and `static/` to output directory
  def copy_assets() do
    Ego.FileSystem.copy_all(
      FileSystem.assets_paths(),
      FileSystem.output_path("")
    )
  end
end
