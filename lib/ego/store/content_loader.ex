defmodule Ego.Store.ContentLoader do
  require Logger

  def load_all(directory_path, opts \\ []) do
    root = opts[:root]
    path = Path.join(root, directory_path)

    if File.dir?(path) do
      documents = load_directory(directory_path, opts)

      {:ok, documents}
    else
      {:error, :not_found}
    end
  end

  def load_directory(directory_path, opts \\ []) do
    root = opts[:root]

    path = Path.join(root, directory_path)

    documents =
      File.ls!(path)
      |> Enum.map(fn file ->
        full_path = Path.join(path, file)

        cond do
          File.dir?(full_path) ->
            load_directory(Path.join(directory_path, file), opts)

          String.ends_with?(file, ".md") and file != "_index.md" ->
            [load_file(Path.join(directory_path, file), root)]

          true ->
            []
        end
      end)
      |> Enum.concat()
      |> Enum.reject(&is_nil(&1))
      |> Enum.sort_by(& &1.params["weight"])

    index =
      if File.exists?(Path.join(path, "_index.md")) do
        load_file(Path.join(directory_path, "_index.md"), root)
      end

    if index do
      [%{index | children: documents, has_children: true}]
    else
      documents
    end
  end

  def load_file(file, directory) do
    Logger.info("Parsing file: #{file}")
    content = File.read!(Path.join(directory, file))

    doc =
      case String.split(content, ~r/\r*\n-{3,}\r*\n*/, parts: 2) do
        [frontmatter, markdown] ->
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

        [head | _tail] ->
          section =
            file
            |> String.replace_trailing("/_index.md", "")
            |> String.replace("/", "")

          section = (section == "" && "root") || section

          {
            section,
            String.to_atom(head)
          }
      end

    slug = Path.basename(file, ".md")

    path = String.replace(file, ~r/[\/]?(_index)*\.md$/, "")

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
