defmodule Ego.Config do
  def load() do
    path = Ego.FileSystem.source_path("config.yml")

    with {:file, {:ok, content}} <- {:file, File.read(path)},
         {:ok, config} <- YamlElixir.read_from_string(content) do
      {:ok, config}
    else
      {:file, _} -> {:error, "Can not found config file at #{path}"}
      _ -> {:error, "Invalid config"}
    end
  end
end
