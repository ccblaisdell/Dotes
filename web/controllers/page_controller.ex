defmodule DotaQuantifyElixir.PageController do
  use DotaQuantifyElixir.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
