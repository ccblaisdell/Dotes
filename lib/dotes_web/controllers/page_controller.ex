defmodule DotesWeb.PageController do
  use Dotes.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
