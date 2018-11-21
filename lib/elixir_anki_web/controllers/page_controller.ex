defmodule ElixirAnkiWeb.PageController do
  use ElixirAnkiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
