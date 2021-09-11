defmodule Ego.Server.PageController do
  use Ego.Server, :controller

  def index(conn, _params) do
    document = Ego.DocumentStore.find(%{"type" => "page", "slug" => "index"})
    content = Ego.Renderer.render("index", build_assigns(%{"document" => document}), type: "page")

    html(conn, content)
  end

  def show(conn, %{"slug" => slug}) do
    document = Ego.DocumentStore.find(%{"type" => "page", "slug" => slug})

    if document do
      content =
        Ego.Renderer.render(
          [document["layout"], "single"],
          build_assigns(%{"document" => document}),
          type: "page"
        )

      html(conn, content)
    else
      text(conn, "404 not found")
    end
  end
end
