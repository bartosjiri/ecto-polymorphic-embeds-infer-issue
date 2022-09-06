defmodule PedemoWeb.PageController do
  use PedemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
