defmodule Ego.Context do
  alias Ego.MapHelpers
  defstruct [:template, :lookup_dir, :type, :output_path, layout: "baseof", assigns: %{}]

  def new(params) do
    struct(__MODULE__, params)
    |> put_assign(params[:assigns] || %{})
  end

  def put_template(context, template) do
    struct(context, template: template)
  end

  def put_layout(context, layout) do
    struct(context, layout: layout)
  end

  def put_type(context, type) do
    struct(context, type: type)
    |> put_var(:type, type)
  end

  def put_output_path(context, path) do
    struct(context, output_path: path)
  end

  def put_lookup_dir(context, dir_list) do
    struct(context, lookup_dir: dir_list)
  end

  def put_assign(context, assigns) when is_map(assigns) do
    struct(context, assigns: MapHelpers.to_string_key(assigns))
  end

  def merge_assign(context, assigns) do
    assigns = MapHelpers.to_string_key(assigns)

    struct(context, assigns: Map.merge(context.assigns, assigns))
  end

  def put_var(context, key, value) do
    struct(context,
      assigns: Map.put(context.assigns, to_string(key), MapHelpers.to_string_key(value))
    )
  end
end
