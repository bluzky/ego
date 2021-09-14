defmodule Ego.Template.Filters do
  alias Ego.{UrlHelpers, MapHelpers}
  alias Ego.Store

  def abs_url(input), do: UrlHelpers.url(input || "")
  def rel_url(input), do: UrlHelpers.path(input || "")

  def match(input, pattern) do
    input =~ Regex.compile!(pattern)
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

  def slugify(text), do: Slug.slugify(text || "")

  def urlize(text), do: slugify(text)

  def md5(text), do: text |> :crypto.hash(:md5) |> Base.encode64()

  def markdownify(text) do
    case Earmark.as_html(text || "") do
      {:ok, content, _} -> content
      _error -> nil
    end
  end
end
