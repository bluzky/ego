defmodule Ego.Store do
  @moduledoc """
  Load content file and parse metadata as document
  """

  require Logger
  alias Ego.UrlHelpers

  def init(content_dir, opts \\ []) do
    case Ego.Store.ContentLoader.load_all(content_dir, opts) do
      {:ok, documents} ->
        documents =
          Enum.sort_by(documents, & &1.date, &>=/2)
          |> Enum.reject(& &1.draft)

        Cachex.put(:ego, :documents, documents)

        types =
          Enum.map(documents, & &1.type)
          |> Enum.uniq()
          |> Enum.reject(&is_nil(&1))

        Cachex.put(:ego, :types, types)

        Cachex.put(:ego, :taxonomies, %{
          categories: extract_term(documents, :categories, :category),
          tags: extract_term(documents, :tags, :tag)
        })

        documents

      error ->
        Logger.error("Cannot load content")
        Logger.error(inspect(error))
    end
  end

  defp extract_term(documents, extract_key, type) do
    documents
    |> Enum.map(&(Map.get(&1, extract_key) || []))
    |> Enum.concat()
    |> Enum.group_by(& &1)
    |> Enum.map(fn {name, items} ->
      slug = Slug.slugify(name)

      %Ego.Taxonomy{
        title: name,
        count: length(items),
        slug: slug,
        type: type,
        url: UrlHelpers.url(type, slug),
        path: UrlHelpers.path(type, slug)
      }
    end)
  end

  def list_documents(), do: Cachex.get!(:ego, :documents)
  def all_types(), do: Cachex.get!(:ego, :types)
  def list_taxonomies(), do: Cachex.get!(:ego, :taxonomies)

  def find(documents \\ nil, filters) do
    Enum.find(documents || list_documents(), &match(&1, filters))
  end

  def filter(documents \\ nil, filters) do
    Enum.filter(documents || list_documents(), &match(&1, filters))
  end

  def by_term(documents \\ nil, term, value) do
    term =
      case term do
        :tag -> :tags
        :category -> :categories
        _ -> term
      end

    Enum.filter(documents || list_documents(), fn document ->
      value in Map.get(document, term, [])
    end)
  end

  def by_type(documents \\ nil, type) do
    Enum.filter(documents || list_documents(), fn document ->
      type == to_string(document.type)
    end)
  end

  defp match(document, filters) do
    data = Map.take(document, Map.keys(filters))
    data == filters
  end
end
