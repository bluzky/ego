defmodule Ego.CustomTags do
  defmodule Render do
    require Logger

    def render(context, [template: template_binding], options) do
      template = Solid.Argument.get(template_binding, context)
      vars = Map.merge(context.vars, %{})

      case Ego.Template.render(template, vars, options) do
        {:ok, rendered_data} ->
          rendered_data

        err ->
          Logger.error(inspect(err))
          raise "cannot render template #{template}"
      end
    end
  end
end
