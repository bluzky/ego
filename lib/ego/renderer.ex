defmodule Ego.Renderer do
  alias Ego.TemplateResolver
  alias Ego.FileSystem
  alias Ego.Context
  alias Solid.TemplateError
  alias Ego.UrlHelpers

  require Logger

  def render_index(context, document, assigns \\ %{}) do
    context
    |> Context.put_type(:page)
    |> Context.put_var(:document, document)
    |> Context.put_var(:section, "index")
    |> Context.put_var(:current_url, UrlHelpers.url(:page, nil, assigns[:page]))
    |> Context.put_var(:current_path, UrlHelpers.path(:page, nil, assigns[:page]))
    |> render("index", assigns)
  end

  def render_page(context, document, assigns \\ %{}) do
    context
    |> Context.put_type(:page)
    |> Context.put_var(:document, document)
    |> Context.put_var(:section, document.slug)
    |> Context.put_var(:current_url, UrlHelpers.url(document.path))
    |> Context.put_var(:current_path, document.path)
    |> render([document.layout, "single"], assigns)
  end

  def render_content_index(context, [doc | _] = documents, assigns \\ %{}) do
    context
    |> Context.put_type(doc.type)
    |> Context.put_var(:documents, documents)
    |> Context.put_var(:section, doc.type)
    |> Context.put_var(:current_url, UrlHelpers.url(doc.type, nil, assigns[:page]))
    |> Context.put_var(:current_path, UrlHelpers.path(doc.type, nil, assigns[:page]))
    |> render("list", assigns)
  end

  def render_content_page(context, document, assigns \\ %{}) do
    context
    |> Context.put_type(document.type)
    |> Context.put_var(:document, document)
    |> Context.put_var(:section, document.type)
    |> Context.put_var(:current_url, UrlHelpers.url(document.path))
    |> Context.put_var(:current_path, document.path)
    |> render("single", assigns)
  end

  def render_term_index(context, [term | _] = terms, assigns \\ %{}) do
    context
    |> Context.put_type(term.type)
    |> Context.put_var(:terms, terms)
    |> Context.put_var(:section, term.type)
    |> Context.put_var(:current_url, UrlHelpers.url(term.type, nil, assigns[:page]))
    |> Context.put_var(:current_path, UrlHelpers.path(term.type, nil, assigns[:page]))
    |> render(["terms", "list"], assigns)
  end

  def render_term_page(context, term, assigns \\ %{}) do
    context
    |> Context.put_type(term.type)
    |> Context.put_var(:term, term)
    |> Context.put_var(:section, term.type)
    |> Context.put_var(:current_url, UrlHelpers.url(term.type, term.slug, assigns[:page]))
    |> Context.put_var(:current_path, UrlHelpers.path(term.type, term.slug, assigns[:page]))
    |> render(["term", "single"], assigns)
  end

  def render(context, template, assigns \\ %{}) do
    lookup_dir = context.lookup_dir || FileSystem.lookup_dir(context.type) || ["."]
    fs = TemplateResolver.new(lookup_dir)

    opts = [
      file_system: {TemplateResolver, fs},
      parser: Ego.Template.Parser,
      tags: %{"with" => Ego.Template.WithTag, "paginate" => Ego.Template.PaginateTag}
    ]

    context = Context.merge_assign(context, Map.new(assigns))

    try do
      content =
        TemplateResolver.read_template_file(template, fs)
        |> Solid.parse!(opts)
        |> Solid.render(context.assigns, opts)
        |> to_string()

      TemplateResolver.reset(fs)
      context = Context.put_var(context, :inner_content, content)

      content =
        TemplateResolver.read_template_file(context.layout || "baseof", fs)
        |> Solid.parse!(opts)
        |> Solid.render(context.assigns, opts)
        |> to_string

      {:ok, content}
    rescue
      err in TemplateError ->
        Logger.error(err.message)

        {:error, err.message}
    after
      TemplateResolver.reset(fs)
    end
  end
end
