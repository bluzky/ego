defmodule Ego.Renderer do
  alias Ego.TemplateResolver

  def render({template, layout}, lookup_dir, assigns) do
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
        |> Solid.render(Map.put(assigns, "inner_content", content), file_system: {TemplateResolver, fs})
        |> to_string
    after
      TemplateResolver.reset(fs)
    end
  end

  def render(template, lookup_dir, assigns) do
    render({template, nil}, lookup_dir, assigns)
  end
end
