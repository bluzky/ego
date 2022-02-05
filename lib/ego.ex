defmodule Ego do
  def build do
    Application.ensure_all_started(:cachex)
    Application.ensure_all_started(:ego)
    Ego.Application.start(:normal, [])

    filters = Application.get_env(:solid, :custom_filters)
    filters.md5("ego")
    Ego.Builder.build()
  end

  def server() do
    Application.ensure_all_started(:cachex)
    Application.ensure_all_started(:ego)
    Ego.Application.start(:normal, server: true)
  end

  def new_site(site_name) do
    dir =
      site_name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]/, "_")

    case File.mkdir(dir) do
      :ok ->
        create_site_structure(dir)
        init_content(dir)

      {:error, :eexist} ->
        IO.warn("Directory #{dir} is already exist")

      {:error, error} ->
        IO.warn("Cannot create directory #{dir} with error #{error}")
    end
  end

  defp create_site_structure(dir) do
    File.mkdir_p!(Path.join(dir, "content/blog"))
    File.mkdir!(Path.join(dir, "static"))
    File.mkdir!(Path.join(dir, "themes"))
  end

  defp init_content(site_dir) do
    dir = Application.app_dir(:ego)
    zip_file = Unzip.LocalFile.open(Path.join(dir, "ego"))
    File.cd!(site_dir)

    case Unzip.new(zip_file) do
      {:ok, unzip} ->
        Unzip.file_stream!(unzip, "bookworm.zip")
        |> Stream.into(File.stream!("bookworm.zip", [:write, :raw]))
        |> Stream.run()

        :zip.unzip("bookworm.zip")

      {:error, error} ->
        IO.warn("ERROR: create new site with error #{inspect(error)}")
    end
  end
end
