defmodule Ego.Store.DocumentProcessor do
  alias Ego.UrlHelpers

  def flatten_tree(doc_tree) do
    Enum.map(doc_tree, fn document ->
      if document.has_children do
        children = flatten_tree(document.children)

        document = Map.delete(document, :children)

        [document | children]
      else
        [document]
      end
    end)
    |> Enum.concat()
  end

  def extract_term(documents, extract_key, type) do
    terms =
      documents
      |> Enum.map(&(Map.get(&1, extract_key) || []))
      |> Enum.concat()
      |> Enum.group_by(& &1)
      |> Enum.map(fn {name, items} ->
        slug = Slug.slugify(name)

        %Ego.Document{
          title: name,
          count: length(items),
          slug: slug,
          type: type,
          section: type,
          url: UrlHelpers.url(type, slug),
          path: UrlHelpers.path(type, slug)
        }
      end)

    %{
      page: %Ego.Document{
        title: Phoenix.Naming.humanize(type),
        count: length(terms),
        slug: type,
        type: type,
        section: type,
        url: UrlHelpers.url(type, nil),
        path: UrlHelpers.path(type, nil),
        list_page: true
      },
      terms: terms
    }
  end

  def extract_menu(documents) do
    menu_group =
      documents
      |> Enum.map(fn doc ->
        if is_map(doc.params["menu"]) do
          menu_item = %{
            name: doc.title,
            identifier: doc.slug,
            url: doc.path,
            weight: doc.params["weight"],
            page: doc,
            has_children: false,
            children: []
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
end
