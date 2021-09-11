defmodule Ego.Renderer do
  alias Ego.TemplateResolver
  alias Ego.FileSystem

  def render(template, assigns, opts \\ [])

  def render({template, layout}, assigns, opts) do
    lookup_dir = opts[:lookup_dir] || FileSystem.lookup_dir(opts[:type]) || ["."]
    fs = TemplateResolver.new(lookup_dir)

    try do
      content =
        TemplateResolver.read_template_file(template, fs)
        |> Solid.parse!()
        |> Solid.render(assigns, file_system: {TemplateResolver, fs})
        |> to_string()

      TemplateResolver.reset(fs)

      html =
        TemplateResolver.read_template_file(layout || "baseof", fs)
        |> Solid.parse!()
        |> Solid.render(Map.put(assigns, "inner_content", content),
          file_system: {TemplateResolver, fs}
        )
        |> to_string
    after
      TemplateResolver.reset(fs)
    end
  end

  def render(template, assigns, opts) do
    render({template, nil}, assigns, opts)
  end
end
