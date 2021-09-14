defmodule Ego.MapHelpers do
  def to_string_key(data) when is_map(data) do
    data
    |> Map.delete(:__struct__)
    |> Enum.map(fn {k, v} ->
      {to_string(k), to_string_key(v)}
    end)
    |> Enum.into(%{})
  end

  def to_string_key(data) when is_list(data) do
    Enum.map(data, &to_string_key(&1))
  end

  def to_string_key(value) when is_atom(value) and value not in [true, false, nil],
    do: to_string(value)

  def to_string_key(value), do: value
end
