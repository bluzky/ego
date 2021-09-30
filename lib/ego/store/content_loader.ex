defmodule Ego.Store.ContentLoader do
  require Logger

  def load_all(directory_path, opts \\ []) do
    path = Path.expand(directory_path) <> "/"

    if File.dir?(path) do
      documents =
        list_file(path)
        |> Enum.filter(&String.ends_with?(&1, ".md"))
        |> Enum.map(&String.replace(&1, path, ""))
        |> Enum.map(&load_file(&1, path))

      {:ok, documents}
    else
      {:error, :not_found}
    end
  end

  # list all file in directory recursively
  defp list_file(path) do
    cond do
      File.regular?(path) ->
        [path]

      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&list_file/1)
        |> Enum.concat()

      true ->
        []
    end
  end

  def load_file(file, directory) do
    Logger.info("Parsing file: #{file}")
    content = File.read!(Path.join(directory, file))

    doc =
      case String.split(content, ~r/\r*\n-{3,}\r*\n*/, parts: 2) do
        [frontmatter, markdown] ->
          IO.inspect(frontmatter)

          meta = YamlElixir.read_from_string!(frontmatter)
          {html, text, toc} = parse_markdown(markdown)

          %Ego.Document{
            file: file,
            content: html,
            plain: text,
            title: meta["title"],
            categories: meta["categories"] || [],
            tags: meta["tags"] || [],
            author: meta["author"],
            draft: meta["draft"],
            layout: meta["layout"],
            date: meta["date"],
            image: meta["image"],
            params: Map.drop(meta, ~w(title categories tags author draft layout date image)),
            toc: toc
          }

        [markdown] ->
          {html, text, toc} = parse_markdown(markdown)

          %Ego.Document{
            content: html,
            plain: text,
            toc: toc
          }
      end

    {section, type} =
      case String.replace_leading(file, "/", "") |> String.split("/") do
        [head | []] ->
          slug = String.replace_trailing(head, ".md", "")

          section =
            if slug == "_index" do
              "home"
            else
              slug
            end

          {section, :page}

        [head | tail] ->
          {
            String.replace(file, ~r/\/[^\/]+$/, ""),
            String.to_atom(head)
          }
      end

    slug = Path.basename(file, ".md")

    path =
      String.replace_trailing(file, ".md", "")
      |> String.replace_trailing("/_index", "")

    struct(doc,
      type: type,
      slug: slug,
      section: section,
      list_page: slug == "_index",
      url: Ego.UrlHelpers.url(path),
      path: Path.join("/", path)
    )
  end

  defp parse_markdown(content) do
    ast = Ego.Markdown.parse!(content)

    toc =
      Ego.Markdown.extract_toc(ast)
      |> Ego.Markdown.toc_to_html()

    {Ego.Markdown.to_html(ast), Ego.Markdown.to_text(ast), toc}
  end
end
