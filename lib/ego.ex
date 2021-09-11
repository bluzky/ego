defmodule Ego do
  alias Ego.Store
  alias Ego.FileSystem

  def build do
    assigns = %{
      "site" => %{
        "documents" => Store.all_documents()
      }
    }

    Ego.Builder.build(assigns)
  end
end
