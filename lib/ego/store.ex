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
          categories: extract_term(documents, :categories, :categories),
          tags: extract_term(documents, :tags, :tags)
        })

        extract_menu(documents)

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

  defp extract_menu(documents) do
    menu_group =
      documents
      |> Enum.map(fn doc ->
        if is_map(doc.params["menu"]) do
          menu_item = %{
            name: doc.title,
            identifier: doc.slug,
            url: doc.path,
            weight: doc.params["weight"]
          }

          Enum.map(doc.params["menu"], fn
            {menu, %{} = config} ->
              menu_item
              |> Map.merge(to_atom_map(config))
              |> Map.put(:menu, menu)

            menu ->
              Map.put(menu_item, :menu, menu)
          end)
        else
          nil
        end
      end)
      |> Enum.reject(&is_nil(&1))
      |> Enum.concat()
      |> Enum.sort_by(& &1.weight)
      |> Enum.group_by(& &1.parent)

    # append child from document to config menu
    menus =
      Application.get_env(:ego, :site_config)
      |> Map.get("menus", [])
      |> Enum.map(fn {menu, items} ->
        items =
          items
          |> Enum.map(&to_atom_map/1)
          |> Enum.sort_by(& &1.weight)
          |> build_menu(menu_group)

        {menu, items}
      end)
      |> Enum.into(%{})

    # update site config
    Application.get_env(:ego, :site_config)
    |> Map.put("menus", menus)
    |> then(&Application.put_env(:ego, :site_config, &1))

    menus
  end

  defp build_menu(items, grouped_items) do
    Enum.map(items, fn item ->
      identifier = item[:identifier] || item[:name]

      if grouped_items[identifier] do
        Map.merge(item, %{
          has_children: true,
          children: build_menu(grouped_items[identifier], grouped_items)
        })
      else
        item
      end
    end)
  end

  defp to_atom_map(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
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
