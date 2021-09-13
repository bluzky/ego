defmodule Ego.Taxonomy do
  defstruct [:type, :title, :slug, :url, :path, count: 0]

  @type t :: %{
          type: atom(),
          title: binary(),
          count: integer(),
          slug: binary(),
          url: binary(),
          path: binary()
        }
end
