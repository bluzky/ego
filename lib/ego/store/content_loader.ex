defmodule Ego.Store.ContentLoader do
  def load_all(directory_path, opts \\ []) do
    path = Path.expand(directory_path)
    type = opts[:type]

    if File.dir?(path) do
      documents =
        File.ls!(path)
        |> Enum.map(fn file ->
          path = Path.join(path, file)

          cond do
            File.dir?(path) ->
              case load_all(path, Keyword.put(opts, :type, type || file)) do
                {:ok, documents} -> documents
                _ -> []
              end

            String.ends_with?(file, ".md") ->
              [load_file(path, opts)]

            true ->
              []
          end
        end)
        |> Enum.concat()

      {:ok, documents}
    else
      {:error, :not_found}
    end
  end

  def load_file(file, opts \\ []) do
    content = File.read!(file)

    doc =
      case String.split(content, ~r/\r*\n-{3,}\r*\n*/, parts: 2) do
        [frontmatter, markdown] ->
          meta = YamlElixir.read_from_string!(frontmatter)

          %Ego.Document{
            content: md_to_html(markdown),
            plain: markdown,
            title: meta["title"],
            categories: meta["categories"] || [],
            tags: meta["tags"] || [],
            author: meta["author"],
            draft: meta["draft"],
            layout: meta["layout"],
            date: meta["date"],
            image: meta["image"],
            params: Map.drop(meta, ~w(title categories tags author draft layout date image))
          }

        markdown ->
          %Ego.Document{content: md_to_html(markdown)}
      end

    type =
      if type = opts[:type] do
        String.to_atom(type)
      else
        doc.type
      end

    slug = Path.basename(file, ".md")

    struct(doc,
      type: type,
      slug: slug,
      url: Ego.UrlHelpers.url(type, slug),
      path: Ego.UrlHelpers.path(type, slug)
    )
  end

  defp md_to_html(content) do
    Earmark.as_html!(content)
  end
end
