defmodule MyParser do
  import NimbleParsec

  space = string(" ") |> times(min: 0)
  identifier = ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_, ?-, ??], min: 1)

  plus = string("+")
  minus = string("-")

  true_value =
    string("true")
    |> replace(true)

  false_value =
    string("false")
    |> replace(false)

  null =
    string("nil")
    |> replace(nil)

  int =
    optional(minus)
    |> concat(integer(min: 1))
    |> reduce({Enum, :join, [""]})
    |> map({String, :to_integer, []})

  frac =
    string(".")
    |> concat(integer(min: 1))

  exp =
    choice([string("e"), string("E")])
    |> optional(choice([plus, minus]))
    |> integer(min: 1)

  float =
    int
    |> concat(frac)
    |> optional(exp)
    |> reduce({Enum, :join, [""]})
    |> map({String, :to_float, []})

  single_quoted_string =
    ignore(string(~s(')))
    |> repeat(
      lookahead_not(ascii_char([?']))
      |> choice([string(~s(\')), utf8_char([])])
    )
    |> ignore(string(~s(')))
    |> reduce({List, :to_string, []})

  double_quoted_string =
    ignore(string(~s(")))
    |> repeat(
      lookahead_not(ascii_char([?"]))
      |> choice([string(~s(\")), utf8_char([])])
    )
    |> ignore(string(~s(")))
    |> reduce({List, :to_string, []})

  bracket_access =
    ignore(string("["))
    |> choice([int, single_quoted_string, double_quoted_string])
    |> ignore(string("]"))

  dot_access =
    ignore(string("."))
    |> concat(identifier)

  field =
    identifier
    |> repeat(choice([dot_access, bracket_access]))
    |> tag(:field)

  value =
    choice([
      float,
      int,
      true_value,
      false_value,
      null,
      single_quoted_string,
      double_quoted_string
    ])
    |> unwrap_and_tag(:value)

  argument_name =
    ascii_string([?a..?z, ?A..?Z], 1)
    |> concat(ascii_string([?a..?z, ?A..?Z, ?_], min: 0))
    |> reduce({Enum, :join, []})

  argument =
    choice([value, field])
    |> lookahead_not(string(":"))

  named_argument =
    argument_name
    |> ignore(string(":"))
    |> ignore(space)
    |> choice([value, field])

  arg_separator =
    optional(space)
    |> concat(string(","))
    |> optional(space)

  positional_arguments =
    repeat(
      argument
      |> ignore(space)
      |> ignore(string(","))
      |> ignore(space)
    )
    |> optional(argument)

  named_arguments =
    named_argument
    |> repeat(
      ignore(space)
      |> ignore(string(","))
      |> ignore(space)
      |> concat(named_argument)
    )
    |> tag(:named_arguments)

  arguments = choice([named_arguments, positional_arguments])

  opening_tag = string("{%")
  closing_tag = string("%}")

  custom_tag =
    ignore(opening_tag)
    |> ignore(space)
    |> concat(string("render"))
    |> ignore(space)
    |> tag(optional(named_arguments), :arguments)
    # |> tag(
    #   optional(
    #     positional_arguments
    #     |> ignore(string(","))
    #     |> ignore(space)
    #     |> concat(named_arguments)
    #   ),
    #   :arguments
    # )
    |> ignore(space)
    |> ignore(closing_tag)
    |> tag(:custom_tag)

  mix_arguments =
    tag(
      optional(positional_arguments)
      |> optional(
        ignore(space)
        |> concat(named_arguments)
      ),
      :arguments
    )

  filter_name =
    ascii_string([?a..?z, ?A..?Z], 1)
    |> concat(ascii_string([?a..?z, ?A..?Z, ?_], min: 0))
    |> reduce({Enum, :join, []})

  filter =
    ignore(space)
    |> ignore(string("|"))
    |> ignore(space)
    |> concat(filter_name)
    |> tag(optional(ignore(string(":")) |> ignore(space) |> concat(arguments)), :arguments)
    |> tag(:filter)

  defparsec(:filter, filter)
  defparsec(:argument, mix_arguments)
end
