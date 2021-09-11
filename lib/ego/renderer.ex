defmodule Ego.Renderer do
  alias Ego.TemplateResolver
  alias Ego.FileSystem
  alias Ego.Context

  def render(context, template, assigns \\ %{})

  def render(context, template, assigns) do
    lookup_dir = context.lookup_dir || FileSystem.lookup_dir(context.section) || ["."]
    fs = TemplateResolver.new(lookup_dir)
    opts = [file_system: {TemplateResolver, fs}]

    context = Context.merge_assign(context, Map.new(assigns))

    try do
      content =
        TemplateResolver.read_template_file(template, fs)
        |> Solid.parse!()
        |> Solid.render(context.assigns, opts)
        |> to_string()

      TemplateResolver.reset(fs)
      context = Context.put_var(context, :inner_content, content)

      TemplateResolver.read_template_file(context.layout || "baseof", fs)
      |> Solid.parse!()
      |> Solid.render(context.assigns, opts)
      |> to_string
    after
      TemplateResolver.reset(fs)
    end
  end
end
