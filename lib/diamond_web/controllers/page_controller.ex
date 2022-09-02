defmodule DiamondWeb.PageController do
  use DiamondWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
