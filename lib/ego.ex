defmodule Ego do
  alias Ego.Document
  alias Ego.Renderer

  def build do
    {:ok, documents} = Document.load_content("priv/content")

    assigns = %{
      "site" => %{
        "documents" => documents
      }
    }

    Renderer.render(assigns)
  end
end
