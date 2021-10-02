defmodule Ego.FileSystem do
  def lookup_dir(type) when type in ["page", nil] do
    paths = [
      "layouts/",
      "layouts/_default"
    ]

    source_path(paths) ++ theme_path(paths)
  end

  def lookup_dir(type) do
    paths = [
      "layouts/#{type}",
      "layouts/_default",
      "layouts/"
    ]

    source_path(paths) ++ theme_path(paths)
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

  def theme_path(paths) when is_list(paths) do
    theme =
      Application.get_env(:ego, :site_config, %{})
      |> Map.get("theme", "default")

    theme_dir = source_path("/themes/#{theme}")

    Enum.map(paths, fn path ->
      Path.join(theme_dir, path)
    end)
  end

  def theme_path(path) do
    theme_path([path])
    |> List.first()
  end

  def assets_paths() do
    paths =
      source_path(["static/"]) ++
        theme_path(["static/"])

    Enum.filter(paths, fn path ->
      File.exists?(path)
    end)
  end

  def output_dir() do
    Application.get_env(:ego, :config, [])
    |> Keyword.get(:output_dir)
  end

  def output_file(path) do
    output_dir()
    |> Path.join(path)
    |> Path.join("index.html")
  end

  def output_path(rel_path) do
    Path.join(output_dir(), rel_path)
  end

  def write_file(path, content) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content, [:write])
  end

  def copy_all(sources, destination) when is_list(sources) do
    Enum.each(sources, &File.cp_r!(&1, destination))
  end
end
