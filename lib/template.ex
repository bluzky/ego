defmodule Ego.Template do
  def render(template, assigns, options \\ []) do
    tags_renderers = %{
      "render" => Ego.CustomTags.Render
    }

    options = Keyword.put(options, :tags, tags_renderers)
    current_dir = options[:cwd]
    lookup_dir = options[:lookup_dir] || []

    with {:ok, path} <- Ego.TemplateResolver.lookup_template(template, current_dir, lookup_dir),
         options = Keyword.put(options, :cwd, Path.dirname(path)),
         {:ok, template_str} <- File.read(path),
         {:ok, template} <- Solid.parse(template_str, parser: Ego.TemplateParser) do
      Solid.render(template, assigns, options)
    end
  end
end
