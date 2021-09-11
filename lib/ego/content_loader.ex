defmodule Ego.ContentLoader do
  @default_type "page"

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
          frontmatter
          |> YamlElixir.read_from_string!()
          |> Map.put("content", md_to_html(markdown))

        markdown ->
          %{"content" => md_to_html(markdown)}
      end

    Map.merge(doc, %{
      "type" => opts[:type] || @default_type,
      "slug" => Path.basename(file, ".md")
    })
  end

  defp md_to_html(content) do
    Earmark.as_html!(content)
  end
end
