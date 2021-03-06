defmodule EgoWeb.BuildContext do
  import Plug.Conn
  alias Ego.Store
  def init(opts), do: opts

  def call(conn, _opts) do
    site =
      Application.get_env(:ego, :site_config, %{})
      |> Map.put(:documents, Store.list_documents() |> Enum.reject(& &1.list_page))
      |> Map.put(:document_tree, Store.get_document_tree())
      |> Map.put(:taxonomies, Store.list_taxonomies())

    assign(conn, :context, Ego.Context.new(%{assigns: %{site: site}}))
  end
end
