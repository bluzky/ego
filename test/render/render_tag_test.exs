defmodule RenderTagTest do
  use ExUnit.Case
  alias Ego.CustomTags.Render

  # test "include template in lookup directory" do
  #   template = """
  #   {% render "a", "b", c: "hi %}
  #   """

  #   assert "" ==
  #            Solid.parse!(template, parser: Ego.TemplateParser)
  #            |> IO.inspect()
  #            |> Solid.render(nil,
  #              lookup_dir: "test/support/template/default",
  #              tags: %{"render" => Render}
  #            )
  # end

  test "argument" do
    assert {:ok, [arguments: [value: "a", value: "b", value: "c"]], _, _, _, _} =
             MyParser.argument("'a', 'b', 'c' ")

    assert {:ok, [arguments: [named_arguments: ["a", {:value, 1}, "b", {:value, 2}]]], "", _, _,
            _} = MyParser.argument("a: 1, b: 2")

    assert {:ok,
            [
              arguments: [
                value: "a",
                value: "b",
                named_arguments: ["a", {:value, 1}, "b", {:value, 2}]
              ]
            ], "", _, _, _} = MyParser.argument("'a', 'b', a: 1, b: 2")

    assert {:ok, [arguments: [named_arguments: ["a", {:value, 1}, "b", {:value, 2}]]], ", c, d",
            _, _, _} = MyParser.argument("a: 1, b: 2, c, d")

    assert {:ok, [arguments: []], _, _, _, _} = MyParser.argument("")
  end
end
