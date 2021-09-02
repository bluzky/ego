defmodule Ego.TemplateParser do
  use Solid.Parser.Base

  space = string(" ") |> times(min: 0)

  render =
    ignore(string("{%"))
    |> ignore(space)
    |> concat(string("render"))
    |> ignore(space)
    |> tag(@argument, :template)
    |> optional(
      ignore(string(","))
      |> ignore(space)
      |> concat(@named_arguments)
      |> tag(:arguments)
    )
    |> ignore(space)
    |> ignore(string("%}"))
    |> tag(:custom_tag)

  @custom_tags [render]
end
