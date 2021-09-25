defmodule Ego.Builder do
  alias Ego.Store
  alias Ego.Renderer
  alias Ego.FileSystem
  alias Ego.Context

  require Logger

  def build() do
    context = build_context()

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

  defp build_context() do
    site =
      Application.get_env(:ego, :site_config, %{})
      |> Map.put(:documents, Store.list_documents())
      |> Map.put(:taxonomies, Store.list_taxonomies())

    Ego.Context.new(%{assigns: %{site: site}})
  end

  # build page level content
  defp build_content(%{type: :page} = context) do
    document = Store.find(%{type: :page, slug: "index"})
    build_home_page(context, document)

    # do not re build index page
    Store.filter(%{type: :page})
    |> Enum.reject(&(&1.slug == "index"))
    |> Enum.map(fn document ->
      build_single_page(context, document)
    end)
  end

  # build conent for other archetype
  defp build_content(context) do
    documents = Store.filter(%{type: context.type})
    build_list_content(context, documents)

    Enum.map(documents, fn document ->
      build_single_content(context, document)
    end)
  end

  # generate static page for term: category, tag
  defp build_term(context, terms) do
    build_list_term(context, terms)

    Enum.each(terms, fn term ->
      build_single_term(context, term)
    end)
  end

  # build home page
  defp build_home_page(context, document) do
    context
    |> Renderer.render_index(document)
    |> tap(&write_file/1)
    |> handle_paginate(fn page ->
      context
      |> Context.put_var("__current_page", page)
      |> build_home_page(document)
    end)
  end

  # build single page
  defp build_single_page(context, document) do
    context
    |> Renderer.render_page(document)
    |> write_file()
  end

  # build content listing page
  defp build_list_content(context, documents) do
    context
    |> Renderer.render_content_index(documents)
    |> tap(&write_file/1)
    |> handle_paginate(fn page ->
      context
      |> Context.put_var("__current_page", page)
      |> build_list_content(documents)
    end)
  end

  # build content detail page
  defp build_single_content(context, document) do
    context
    |> Renderer.render_content_page(document)
    |> write_file()
  end

  # generate term listing page
  defp build_list_term(context, terms) do
    context
    |> Renderer.render_term_index(terms)
    |> tap(&write_file/1)
    |> handle_paginate(fn page ->
      context
      |> Context.put_var("__current_page", page)
      |> build_list_term(terms)
    end)
  end

  # generate single term page
  # we pass document which match term with context
  defp build_single_term(context, term, documents \\ nil) do
    documents = documents || Store.by_term(context.type, term.title)

    context
    |> Renderer.render_term_page(term, documents: documents)
    |> tap(&write_file/1)
    |> handle_paginate(fn page ->
      context
      |> Context.put_var("__current_page", page)
      |> build_single_term(term, documents)
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
