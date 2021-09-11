defmodule Ego.FileSystem do
  def lookup_dir("page") do
    source_path([
      "layouts/",
      "layouts/_default"
    ])
  end

  def lookup_dir(type) do
    source_path([
      "layouts/#{type}",
      "layouts/_default"
    ])
  end

  def source_path(paths) when is_list(paths) do
    base_dir =
      Application.get_env(:ego, :config)
      |> Keyword.get(:source_dir)

    Enum.map(paths, &Path.join(base_dir, &1))
  end

  def source_path(path) do
    List.first(source_path([path]))
  end

  def output_dir() do
    Application.get_env(:ego, :config, [])
    |> Keyword.get(:output_dir)
  end

  def output_path("page", slug) do
    Path.join(output_dir(), "#{slug}.html")
  end

  def output_path("tag", slug) do
    Path.join(output_dir(), "tags/#{slug}.html")
  end

  def output_path("category", slug) do
    Path.join(output_dir(), "categories/#{slug}.html")
  end

  def output_path(type, slug) do
    Path.join(output_dir(), "#{type}/#{slug}.html")
  end

  def output_path(rel_path) do
    Path.join(output_dir(), rel_path)
  end

  def write_file(path, content) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content, [:write])
  end

  def copy_all(sources, destination) when is_list(sources) do
    Enum.each(sources, &copy_all(&1, destination))
  end

  def copy_all(source, destination) do
    File.cp_r!(source, destination)
  end
end
