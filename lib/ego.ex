defmodule Ego do
  alias Ego.Store
  alias Ego.FileSystem

  def build do
    Ego.Server.Application.start(:normal, [])

    filters = Application.get_env(:solid, :custom_filters)
    filters.md5("ego")
    Ego.build()
  end

  def server() do
    Ego.Server.Application.start(:normal, server: true)
  end
end
