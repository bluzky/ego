defmodule Ego.Server.PageController do
  use Ego.Server, :controller

  def index(conn, params) do
    text(conn, "hello")
  end

  def show(conn, params) do
    text(conn, "show")
  end
end
