defmodule Ego.Context do
  defstruct [:template, :lookup_dir, :section, :output_path, layout: "baseof", assigns: %{}]

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

  def put_section(context, section) do
    struct(context, section: section)
  end

  def put_output_path(context, path) do
    struct(context, output_path: path)
  end

  def put_lookup_dir(context, dir_list) do
    struct(context, lookup_dir: dir_list)
  end

  def put_assign(context, assigns) when is_map(assigns) do
    struct(context, assigns: to_string_key(assigns))
  end

  def merge_assign(context, assigns) do
    assigns = to_string_key(assigns)

    struct(context, assigns: Map.merge(context.assigns, assigns))
  end

  def put_var(context, key, value) do
    struct(context, assigns: Map.put(context.assigns, to_string(key), to_string_key(value)))
  end

  defp to_string_key(data) when is_map(data) do
    data
    |> Map.delete(:__struct__)
    |> Enum.map(fn {k, v} ->
      {to_string(k), to_string_key(v)}
    end)
    |> Enum.into(%{})
  end

  defp to_string_key(data) when is_list(data) do
    Enum.map(data, &to_string_key(&1))
  end

  defp to_string_key(value), do: value
end
