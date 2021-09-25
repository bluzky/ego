defmodule Ego do
  alias Ego.Store
  alias Ego.FileSystem

  def build do
    Ego.Builder.build()
  end
end
