defmodule Ego.Template.Parser do
  use Solid.Parser.Base,
    custom_tags: [Ego.Template.WithTag, Ego.Template.PaginateTag]
end
