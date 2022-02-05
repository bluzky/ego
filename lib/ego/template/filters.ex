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

        _err ->
          input
      end
    end
  end

  @doc """
  Find item that match filter in the list
  """
  def find(list, filters) do
    keys = Map.keys(filters)

    Enum.find(list || [], fn item ->
      Map.take(item, keys) == filters
    end)
  end

  @doc """
  Find all item which value in array attribute
  For example each document.categories is a list then you want to find all document
  with category `example`
      where_in(documents, "categories", "example")
  """
  def where_in(list, attribute, value) do
    Enum.filter(list || [], fn item ->
      value in Map.get(item, attribute, [])
    end)
  end

  def slugify(text), do: Slug.slugify(text || "")

  def urlize(text), do: slugify(text)

  def humanize(text), do: Phoenix.Naming.humanize(text || "")

  def md5(nil), do: nil

  def md5(text), do: text |> then(&:crypto.hash(:md5, &1)) |> Base.encode64()

  def markdownify(text) do
    try do
      case Earmark.as_html(text || "") do
        {:ok, content, _} -> content
        _error -> nil
      end
    rescue
      _e -> text
    end
  end

  def dump(input) do
    text = Kernel.inspect(input)
    IO.puts(text)
    text
  end

  # work with menu
  def is_current_menu(menu, page) do
    menu["page"] && get_in(menu, ["page", "path"]) == page["path"]
  end

  def has_child_menu(menu, page) do
    Enum.find_value(menu["children"] || [], false, fn item ->
      if is_current_menu(item, page) do
        true
      else
        has_child_menu(item, page)
      end
    end)
  end

  # work with document tree
  @doc """
  Find node of given document tree which match the given path
  """
  def find_node(tree, path) when is_map(tree) do
    find_node(tree["children"], path)
  end

  def find_node(tree, path) do
    node =
      Enum.find(tree, fn node ->
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

  @doc """
  Check if a path point to a child node of document tree
  """
  def has_node(tree, path) do
    not is_nil(find_node(tree, path))
  end

  @doc """
  List all parents nodes of given document
  """
  def get_ancestors(nodes, document, acc \\ []) when is_list(nodes) do
    node =
      Enum.find(nodes, fn node ->
        String.starts_with?(document["path"], node["path"])
      end)

    cond do
      node["path"] == document["path"] ->
        Enum.reverse(acc)

      not is_nil(node) ->
        get_ancestors(node["children"] || [], document, [node | acc])

      true ->
        []
    end
  end
end
