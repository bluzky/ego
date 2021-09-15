defmodule Ego.Template.Parser do
  use Solid.Parser.Base, custom_tags: [{"with", Ego.Template.WithTag}]
end
