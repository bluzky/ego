defmodule Ego.PathHelpers do
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

  def path(type, slug) do
    "/#{type}/#{slug}"
  end
end
