defmodule DotaQuantify.PageController do
  use DotaQuantify.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
