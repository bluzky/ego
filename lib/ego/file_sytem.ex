defmodule Ego.FileSystem do
  def lookup_dir("page") do
    expand([
      "layouts/",
      "layouts/_default"
    ])
  end

  def lookup_dir(type) do
    expand([
      "layouts/#{type}",
      "layouts/_default"
    ])
  end

  defp expand(paths) when is_list(paths) do
    base_dir =
      Application.get_env(:ego, :config)
      |> Keyword.get(:source_dir)

    Enum.map(paths, &Path.join(base_dir, &1))
  end

  defp expand(path) do
    List.first(expand([path]))
  end

  def output_dir() do
    Application.get_env(:ego, :config, [])
    |> Keyword.get(:output_dir)
  end

  def output_path("page", slug) do
    Path.join(output_dir(), "#{slug}.html")
  end

  def output_path(type, slug) do
    Path.join(output_dir(), "#{type}/#{slug}.html")
  end

  def write_file(path, content) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content, [:write])
  end
end
