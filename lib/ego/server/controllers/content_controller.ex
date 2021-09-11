defmodule Ego.Server.ContentController do
  use Ego.Server, :controller

  def index(conn, params) do
    text(conn, "index content")
  end

  def show(conn, params) do
    text(conn, "show content")
  end
end
