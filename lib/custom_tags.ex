defmodule Ego.CustomTags do
  defmodule Render do
    def render(context, [template: template_binding], options) do
      template = Solid.Argument.get(template_binding, context)
      current_dir = options[:cwd]
      lookup_dir = options[:lookup_dir] || []

      case Ego.TemplateResolver.lookup_template(template, current_dir, lookup_dir) do
        {:ok, path} ->
          vars = Map.merge(context.vars, %{})
          options = Keyword.put(options, :cwd, Path.dirname(path))

          Ego.Template.render(path, vars, options)

        _ ->
          raise "Template #{template} not found in #{current_dir} or #{inspect(lookup_dir)}"
      end
    end
  end
end
