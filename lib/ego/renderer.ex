defmodule Ego.Renderer do
  alias Ego.TemplateResolver
  alias Ego.FileSystem
  alias Ego.Context
  alias Solid.TemplateError

  require Logger

  def render_index(context, document, assigns \\ %{}) do
    context
    |> Context.put_type(:page)
    |> Context.put_var(:document, document)
    |> Context.put_var(:section, "index")
    |> render("index", assigns)
  end

  def render_page(context, document, assigns \\ %{}) do
    context
    |> Context.put_type(:page)
    |> Context.put_var(:document, document)
    |> Context.put_var(:section, document.slug)
    |> render([document.layout, "single"], assigns)
  end

  def render_content_index(context, [doc | _] = documents, assigns \\ %{}) do
    context
    |> Context.put_type(doc.type)
    |> Context.put_var(:documents, documents)
    |> Context.put_var(:section, doc.type)
    |> render("list", assigns)
  end

  def render_content_page(context, document, assigns \\ %{}) do
    context
    |> Context.put_type(document.type)
    |> Context.put_var(:document, document)
    |> Context.put_var(:section, document.type)
    |> render("single", assigns)
  end

  def render_term_index(context, [term | _] = terms, assigns \\ %{}) do
    context
    |> Context.put_type(term.type)
    |> Context.put_var(:terms, terms)
    |> Context.put_var(:section, term.type)
    |> render(["terms", "list"], assigns)
  end

  def render_term_page(context, term, assigns \\ %{}) do
    context
    |> Context.put_type(term.type)
    |> Context.put_var(:term, term)
    |> Context.put_var(:section, term.type)
    |> render(["term", "single"], assigns)
  end

  def render(context, template, assigns \\ %{}) do
    lookup_dir = context.lookup_dir || FileSystem.lookup_dir(context.type) || ["."]
    fs = TemplateResolver.new(lookup_dir)

    opts = [
      file_system: {TemplateResolver, fs},
      parser: Ego.Template.Parser,
      tags: %{"with" => Ego.Template.WithTag}
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
