defmodule Ego do
  alias Ego.DocumentStore
  alias Ego.FileSystem

  def build do
    assigns = %{
      "site" => %{
        "documents" => DocumentStore.all_documents()
      }
    }

    Ego.Builder.build(assigns)
  end
end
