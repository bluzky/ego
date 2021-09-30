defmodule Ego.Store do
  @moduledoc """
  Load content file and parse metadata as document
  """

  require Logger
  alias Ego.Store.DocumentProcessor

  def init(content_dir, opts \\ []) do
    case Ego.Store.ContentLoader.load_all("", root: content_dir) do
      {:ok, doc_tree} ->
        documents =
          doc_tree
          |> DocumentProcessor.flatten_tree()
          |> Enum.sort_by(& &1.date, &>=/2)
          |> Enum.reject(& &1.draft)

        Cachex.put(:ego, :documents, documents)
        Cachex.put(:ego, :document_tree, doc_tree)

        types =
          Enum.map(documents, & &1.type)
          |> Enum.uniq()
          |> Enum.reject(&is_nil(&1))

        Cachex.put(:ego, :types, types)

        Cachex.put(:ego, :taxonomies, %{
          categories: DocumentProcessor.extract_term(documents, :categories, :categories),
          tags: DocumentProcessor.extract_term(documents, :tags, :tags)
        })

        DocumentProcessor.extract_menu(documents)

        documents

      error ->
        Logger.error("Cannot load content")
        Logger.error(inspect(error))
    end
  end

  def list_documents(), do: Cachex.get!(:ego, :documents)
  def get_document_tree(), do: Cachex.get!(:ego, :document_tree)
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
