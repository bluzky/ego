defmodule Ego.Document do
  defstruct [
    :title,
    :slug,
    :author,
    :content,
    :layout,
    :image,
    :url,
    type: :page,
    categories: [],
    tags: [],
    draft: true,
    date: DateTime.utc_now(),
    extra: %{}
  ]

  @type t :: %{
          type: binary,
          title: binary,
          slug: binary,
          categories: list(binary),
          tags: list(binary),
          author: binary,
          content: binary,
          draft: boolean,
          layout: binary,
          date: NaiveDateTime.t(),
          image: binary(),
          url: binary(),
          extra: map()
        }
end
