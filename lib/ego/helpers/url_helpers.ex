defmodule Ego.UrlHelpers do
  def page_path(slug) do
    path(:page, slug)
  end

  def tag_path(slug \\ nil) do
    path(:tag, slug)
  end

  def category_path(slug \\ nil) do
    path(:category, slug)
  end

  def content_path(type, slug \\ nil) do
    path(type, slug)
  end

  def path(type, slug \\ nil)

  def path(:page, slug) do
    "/#{slug}"
  end

  def path(:category, slug) do
    path(:categories, slug)
  end

  def path(:tag, slug) do
    path(:tags, slug)
  end

  def path(type, slug) do
    "/#{type}/#{slug}"
  end

  def url(type, slug) do
    Application.get_env(:ego, :config)
    |> Keyword.get(:base_url, "/")
    |> Path.join(path(type, slug))
  end

  def url(rel_url) do
    Application.get_env(:ego, :config)
    |> Keyword.get(:base_url, "/")
    |> Path.join(rel_url)
  end
end
