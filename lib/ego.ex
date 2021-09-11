defmodule Ego do
  alias Ego.Document

  def build do
    {:ok, documents} = Document.load_content("priv/content")

    assigns = %{
      "site" => %{
        "documents" => documents
      }
    }

    Ego.Builder.build(assigns)
  end
end
