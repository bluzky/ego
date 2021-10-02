defmodule Ego.Document do
  defstruct [
    :file,
    :title,
    :slug,
    :author,
    :content,
    # raw content
    :plain,
    :layout,
    :image,
    :url,
    :path,
    type: :page,
    categories: [],
    tags: [],
    draft: true,
    date: DateTime.utc_now(),
    params: %{},
    toc: nil,
    list_page: false,
    section: "home",
    children: [],
    has_children: false,
    count: 1
  ]

  @type t :: %{
          file: binary(),
          type: binary,
          title: binary,
          slug: binary,
          categories: list(binary),
          tags: list(binary),
          author: binary,
          content: binary,
          plain: binary(),
          draft: boolean,
          layout: binary,
          date: NaiveDateTime.t(),
          image: binary(),
          url: binary(),
          path: binary(),
          params: map(),
          toc: binary(),
          list_page: boolean(),
          section: binary(),
          count: integer()
        }
end
