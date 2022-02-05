defmodule EgoWeb.PageController do
  use EgoWeb, :controller
  alias Ego.Renderer

  action_fallback(EgoWeb.FallbackController)

  def index(conn, params) do
    document = Ego.Store.find(%{section: "home"})

    context =
      if params["page"] do
        Ego.Context.put_var(
          conn.assigns.context,
          :__current_page,
          String.to_integer(params["page"])
        )
      else
        conn.assigns.context
      end

    Renderer.render_page(context, document)
  end

  def show(conn, %{"path" => path}) do
    {path, page} = extract_paging(path)

    document = Ego.Store.find(%{path: path})

    if document do
      context =
        if page do
          Ego.Context.put_var(
            conn.assigns.context,
            :__current_page,
            page
          )
        else
          conn.assigns.context
        end

      Renderer.render_page(context, document)
    else
      text(conn, "404 not found")
    end
  end

  defp extract_paging(path) do
    case Enum.take(path, -2) do
      ["page", page] ->
        path_str =
          path
          |> Enum.slice(0..-3)
          |> Path.join()

        {"/#{path_str}", String.to_integer(page)}

      _ ->
        {Path.join(["/" | path]), nil}
    end
  end
end
