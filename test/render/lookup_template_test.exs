defmodule Ego.LookupTemplateTest do
  use ExUnit.Case
  alias Ego.CustomTags.Render

  def template_path(template) do
    Path.expand(template, "test/support/template/")
  end

  test "lookup template in current dir found" do
    path = template_path("default/a.html")
    assert {:ok, ^path} = Render.lookup_template("a.html", "test/support/template/default", [])
  end

  test "lookup template without extension in current dir found" do
    path = template_path("default/a.html")
    assert {:ok, ^path} = Render.lookup_template("a", "test/support/template/default", [])
  end

  test "lookup template in current dir not found" do
    assert {:error, :not_found} =
             Render.lookup_template("c.html", "test/support/template/default", [])
  end

  test "lookup template not found in cwd but in lookup dir" do
    path = template_path("custom/c.html")

    assert {:ok, ^path} =
             Render.lookup_template("c", "test/support/template/default", [
               "test/support/template/custom"
             ])
  end

  test "lookup template without cwd look in lookup dir found" do
    path = template_path("custom/c.html")

    assert {:ok, ^path} =
             Render.lookup_template("c", nil, [
               "test/support/template/custom"
             ])
  end

  test "lookup template without cwd look in lookup dir not found" do
    assert {:error, :not_found} =
             Render.lookup_template("a", nil, [
               "test/support/template/custom"
             ])
  end

  test "lookup template exist both in cwd and lookup dir but get in cwd first" do
    path = template_path("default/b.html")

    assert {:ok, ^path} =
             Render.lookup_template("b", "test/support/template/default", [
               "test/support/template/custom"
             ])
  end

  test "relative template start with .. only look up in cwd found" do
    path = template_path("default/a.html")

    assert {:ok, ^path} =
             Render.lookup_template("../a", "test/support/template/default/partial", [
               "test/support/template/custom"
             ])
  end

  test "relative template start with .. only look up in cwd even exist in lookup dir return not found" do
    assert {:error, :not_found} =
             Render.lookup_template("../c", "test/support/template/default/partial", [
               "test/support/template/custom/partial"
             ])
  end
end
