defmodule Train2Web.PageController do
  use Train2Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
