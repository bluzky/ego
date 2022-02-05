defmodule EgoWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use EgoWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, message, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> html(message)
  end

  def call(conn, {:ok, content, _context}) do
    html(conn, content)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, content) when is_binary(content) do
    html(conn, content)
  end
end
