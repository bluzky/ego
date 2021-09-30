defmodule Ego.Template.Filters do
  alias Ego.{UrlHelpers, MapHelpers}
  alias Ego.Store

  def abs_url(input), do: UrlHelpers.url(input || "")
  def rel_url(input), do: UrlHelpers.path(input || "")

  def match(input, pattern) do
    input =~ Regex.compile!(pattern)
  end

  def replace_re(input, pattern, to_replace) do
    if input do
      case Regex.compile(pattern) do
        {:ok, reg} ->
          String.replace(input, reg, to_replace)

        err ->
          input
      end
    end
  end

  def get_page(slug, type \\ nil) do
    document =
      if type do
        Store.find(%{slug: slug, type: String.to_existing_atom(type)})
      else
        Store.find(%{slug: slug})
      end

    MapHelpers.to_string_key(document)
  end

  def filter_by_section(documents, section) do
    (documents || [])
    |> Store.filter(%{"type" => section})
    |> MapHelpers.to_string_key()
  end

  def filter_document(value, field) do
    Store.filter(%{:"#{field}" => value})
    |> MapHelpers.to_string_key()
  end

  def slugify(text), do: Slug.slugify(text || "")

  def urlize(text), do: slugify(text)

  def humanize(text), do: Phoenix.Naming.humanize(text || "")

  def md5(nil), do: nil

  def md5(text), do: text |> then(&:crypto.hash(:md5, &1)) |> Base.encode64()

  def markdownify(text) do
    case Earmark.as_html(text || "") do
      {:ok, content, _} -> content
      _error -> nil
    end
  end

  # work with document tree
  def find_node(node, path) when is_map(node) do
    find_node(node["children"], path)
  end

  def find_node(nodes, path) do
    node =
      Enum.find(nodes, fn node ->
        String.starts_with?(path, node["path"])
      end)

    if not is_nil(node) and node["has_children"] do
      if node["path"] == path do
        node
      else
        find_node(node["children"], path)
      end
    else
      node
    end
  end
end
