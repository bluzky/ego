defmodule Ego.TemplateResolver do
  @behaviour Solid.FileSystem

  defstruct [:lookup_dir, :cwd]

  def new(lookup_dir) when is_list(lookup_dir) do
    %__MODULE__{
      lookup_dir: Enum.map(lookup_dir || [], &Path.expand(&1)),
      cwd: File.cwd!()
    }
  end

  def reset(file_system) do
    File.cd!(file_system.cwd)
  end

  def read_template_file(templates, file_system) when is_list(templates) do
    lookup_dir = lookup_dirs(file_system)

    full_path =
      templates
      |> Enum.reject(&is_nil/1)
      |> Enum.find_value(fn template ->
        case lookup_template(template, lookup_dir) do
          {:ok, full_path} -> full_path
          _ -> false
        end
      end)

    if full_path do
      File.cd(Path.dirname(full_path))
      File.read!(full_path)
    else
      raise File.Error,
        path: Enum.join(templates, ","),
        action: "find"
    end
  end

  @impl true
  def read_template_file(template_path, file_system) do
    case lookup_template(template_path, lookup_dirs(file_system)) do
      {:ok, full_path} ->
        File.cd(Path.dirname(full_path))
        File.read!(full_path)

      _err ->
        raise File.Error,
          path: template_path,
          action: "find",
          reason: "No such template '#{template_path}'"
    end
  end

  defp lookup_dirs(file_system) do
    cwd = File.cwd!()

    if Enum.find(file_system.lookup_dir, &String.starts_with?(cwd, &1)) do
      [cwd | file_system.lookup_dir]
    else
      file_system.lookup_dir
    end
  end

  defp lookup_template(template, [lookup_dir | t]) do
    case lookup_template(template, lookup_dir) do
      {:ok, path} -> {:ok, path}
      _error -> lookup_template(template, t)
    end
  end

  defp lookup_template(_, []), do: {:error, :not_found}
  defp lookup_template(_, nil), do: {:error, :not_found}

  defp lookup_template(template, lookup_dir) do
    path1 = Path.expand(template, lookup_dir)
    path2 = Path.expand("#{template}.html", lookup_dir)

    cond do
      File.exists?(path1, raw: true) ->
        {:ok, path1}

      File.exists?(path2, raw: true) ->
        {:ok, path2}

      true ->
        {:error, :not_found}
    end
  end
end
