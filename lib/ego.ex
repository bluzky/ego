defmodule Ego do
  def render(file_path, assigns, opts \\ []) do
    tags_renderers = %{
      "render" => Ego.CustomTags.Render
    }

    opts = Keyword.put(opts, :tags, tags_renderers)

    File.read!(file_path)
    |> Solid.parse!(parser: Ego.TemplateParser)
    |> Solid.render(assigns, opts)
  end
end
