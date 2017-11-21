defmodule CheckerWeb.PageController do
  use CheckerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
