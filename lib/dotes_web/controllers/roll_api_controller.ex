defmodule DotesWeb.RollApiController do
  use Dotes.Web, :controller

  alias Dotes.Roll

  def index(conn, _params) do
    {rolls, users} = get_index_data
    render(conn, "index.json", rolls: rolls, users: users)
  end
  
  defp get_index_data do
    rolls = Roll |> order_by([r], desc: r.inserted_at) |> Repo.all
    users = Dotes.UserCache.all |> elem(1) |> Map.values
    {rolls, users}
  end
end