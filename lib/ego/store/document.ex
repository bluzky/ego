defmodule Ego.Document do
  defstruct [
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
    params: %{}
  ]

  @type t :: %{
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
          params: map()
        }
end
