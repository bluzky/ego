defmodule Ego.DocumentStore do
  @moduledoc """
  Load content file and parse metadata as document
  """

  require Logger

  @type document :: %{
          type: binary,
          title: binary,
          slug: binary,
          categories: list(binary),
          tags: list(binary),
          author: binary,
          content: binary,
          draft: boolean,
          layout: binary,
          date: NaiveDateTime.t()
        }

  def init(content_dir, opts \\ []) do
    case Ego.ContentLoader.load_all(content_dir, opts) do
      {:ok, documents} ->
        documents = Enum.sort_by(documents, & &1["date"], &>=/2)
        Cachex.put(:ego, :documents, documents)

        types =
          Enum.map(documents, & &1["type"])
          |> Enum.uniq()
          |> Enum.reject(&is_nil(&1))

        Cachex.put(:ego, :types, types)

        Cachex.put(:ego, :terms, %{
          "categories" => extract_term(documents, "categories", "category"),
          "tags" => extract_term(documents, "tags", "tag")
        })

        documents

      _ ->
        Logger.error("Cannot load content")
    end
  end

  defp extract_term(documents, extract_key, type) do
    documents
    |> Enum.map(&(Map.get(&1, extract_key) || []))
    |> Enum.concat()
    |> Enum.group_by(& &1)
    |> Enum.map(fn {name, items} ->
      %{
        "title" => name,
        "count" => length(items),
        "slug" => Slug.slugify(name),
        "type" => type
      }
    end)
  end

  def all_documents(), do: Cachex.get!(:ego, :documents)
  def all_types(), do: Cachex.get!(:ego, :types)
  def all_terms(), do: Cachex.get!(:ego, :terms)

  def find(documents \\ nil, filters) do
    Enum.find(documents || all_documents(), &match(&1, filters))
  end

  def filter(documents \\ nil, filters) do
    Enum.filter(documents || all_documents(), &match(&1, filters))
  end

  def by_term(documents \\ nil, term, value) do
    key =
      case term do
        "category" -> "categories"
        "tag" -> "tags"
        _ -> term
      end

    Enum.filter(documents || all_documents(), fn document ->
      value in (document[key] || [])
    end)
  end

  defp match(document, filters) do
    data = Map.take(document, Map.keys(filters))
    data == filters
  end
end
