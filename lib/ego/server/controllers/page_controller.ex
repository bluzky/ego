defmodule Ego.Server.PageController do
  use Ego.Server, :controller
  alias Ego.{Context, Store, Renderer}

  def index(conn, _params) do
    document = Ego.Store.find(%{type: :page, slug: "index"})

    content =
      Context.new(section: :page)
      |> Renderer.render("index", document: document)

    html(conn, content)
  end

  def show(conn, %{"slug" => slug}) do
    document = Ego.Store.find(%{type: :page, slug: slug})

    if document do
      content =
        Context.new(section: :page)
        |> Renderer.render([document.layout, "single"], document: document)

      html(conn, content)
    else
      text(conn, "404 not found")
    end
  end
end
