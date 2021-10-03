defmodule Ego.Renderer do
  alias Ego.TemplateResolver
  alias Ego.FileSystem
  alias Ego.Context
  alias Solid.TemplateError
  alias Ego.UrlHelpers

  require Logger

  def render_page(context, document, assigns \\ %{}) do
    layout =
      cond do
        document.section == "home" -> "index"
        document.list_page -> "list"
        document.layout -> [document.layout, "single"]
        true -> ["single"]
      end

    page = context.assigns["__current_page"]

    context
    |> Context.put_var(:page, document)
    |> Context.put_type(document.type)
    |> Context.put_var(:current_url, UrlHelpers.paginate(document.url, page))
    |> Context.put_var(:current_path, UrlHelpers.paginate(document.path, page))
    |> render(layout, assigns)
  end

  def render_taxonomy(context, document, assigns \\ %{}) do
    page = context.assigns["__current_page"]

    layout =
      cond do
        document.list_page -> ["terms", "list"]
        document.layout -> [document.layout, "single"]
        true -> ["term", "list", "single"]
      end

    context
    |> Context.put_var(:page, document)
    |> Context.put_type(document.type)
    |> Context.put_var(:current_url, UrlHelpers.paginate(document.url, page))
    |> Context.put_var(:current_path, UrlHelpers.paginate(document.path, page))
    |> render(layout, assigns)
  end

  def render(context, template, assigns \\ %{}) do
    Logger.info("Rendering \"#{context.assigns["current_path"]}\"")

    lookup_dir =
      context.lookup_dir || FileSystem.lookup_dir(context.type) ||
        ["."]

    fs = TemplateResolver.new(lookup_dir)

    opts = [
      file_system: {TemplateResolver, fs},
      parser: Ego.Template.Parser,
      template: template
    ]

    context = Context.merge_assign(context, Map.new(assigns))
    solid_context = %Solid.Context{vars: context.assigns}

    try do
      {content, solid_context} =
        TemplateResolver.read_template_file(template, fs)
        |> Solid.parse!(opts)
        |> Map.get(:parsed_template)
        |> Solid.render(solid_context, opts)

      TemplateResolver.reset(fs)
      context = Context.put_var(context, :inner_content, to_string(content))

      content =
        TemplateResolver.read_template_file(context.layout || "baseof", fs)
        |> Solid.parse!(opts)
        |> Solid.render(context.assigns, opts)
        |> to_string

      {:ok, content, solid_context}
    rescue
      err in TemplateError ->
        Logger.error(err.message)

        {:error, err.message, solid_context}
    after
      TemplateResolver.reset(fs)
    end
  end
end
