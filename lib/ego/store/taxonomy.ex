defmodule Ego.Taxonomy do
  defstruct [:type, :title, :slug, :url, count: 0]

  @type t :: %{
          type: atom(),
          title: binary(),
          count: integer(),
          slug: binary(),
          url: binary()
        }
end
