defmodule EgoTest do
  use ExUnit.Case
  doctest Ego

  test "greets the world" do
    assert Ego.hello() == :world
  end
end
