defmodule Ego.Template.WithTag do
  @behaviour Solid.Tag.CustomTag
  import NimbleParsec
  alias Solid.Parser.{Literal, Tag, Variable}

  def spec() do
    space = Literal.whitespace(min: 0)

    ignore(Tag.opening_tag())
    |> ignore(space)
    |> ignore(string("with"))
    |> ignore(space)
    |> tag(Variable.field(), :argument)
    |> ignore(Tag.closing_tag())
    |> tag(parsec(:liquid_entry), :result)
    |> ignore(Tag.opening_tag())
    |> ignore(space)
    |> ignore(string("endwith"))
    |> ignore(space)
    |> ignore(Tag.closing_tag())
  end

  def render(context, [argument: argument, result: result], options) do
    value = Solid.Argument.get(argument, context)

    if value do
      context =
        if is_map(value) do
          %{
            context
            | vars: Map.merge(context.vars, value)
          }
        else
          context
        end

      {rendered, _} = Solid.render(result, context, options)
      [text: rendered]
    else
      [text: ""]
    end
  end
end
