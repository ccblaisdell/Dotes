defmodule DotaQuantify.MatchController do
  use DotaQuantify.Web, :controller

  import Ecto.Query, only: [order_by: 3]

  alias DotaQuantify.Match
  alias DotaQuantify.Player
  alias DotaQuantify.PaginationView, as: Pagination

  plug :scrub_params, "match" when action in [:create, :update]

  def index(conn, params) do
    page = Match
    |> Ecto.Query.order_by([m], desc: m.start_time)
    |> Repo.paginate(params)

    pagination_links = Pagination.pagination_links(page, params)
    pagination_window = Pagination.pagination_window(page)

    render(conn, "index.html", matches: page.entries, page_number: page.page_number,
                               page_size: page.page_size, total_pages: page.total_pages,
                               total_entries: page.total_entries, pagination_links: pagination_links,
                               pagination_window: pagination_window)
  end

  def new(conn, _params) do
    changeset = Match.changeset(%Match{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"match" => %{"match_id" => match_id}}) do
    {:ok, match_params} = DotaApi.match(match_id)
    result = create_match(match_params)
    case result do
      {:ok, _match} ->
        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: match_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create_match(match_params) do
    changeset = Match.changeset(%Match{}, match_params)

    result = Repo.insert(changeset)
    case result do
      {:ok, match} ->
        for player <- match_params["players"] do
          player_params = player |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
          player_changeset = match |> build(:players, player_params)
          Repo.insert(player_changeset)
        end

      _ -> nil
    end

    result
  end

  def show(conn, %{"id" => id}) do
    # match = Match |> Repo.get!(id) |> Repo.preload [:players]
    match = Match 
    |> Repo.get!(id) 
    |> Repo.preload([:players, players: :user])
    render(conn, "show.html", match: match)
  end

  def edit(conn, %{"id" => id}) do
    match = Repo.get!(Match, id)
    changeset = Match.changeset(match)
    render(conn, "edit.html", match: match, changeset: changeset)
  end

  def update(conn, %{"id" => id, "match" => match_params}) do
    match = Repo.get!(Match, id)
    changeset = Match.changeset(match, match_params)

    case Repo.update(changeset) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match updated successfully.")
        |> redirect(to: match_path(conn, :show, match))
      {:error, changeset} ->
        render(conn, "edit.html", match: match, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    match = Repo.get!(Match, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(match)

    conn
    |> put_flash(:info, "Match deleted successfully.")
    |> redirect(to: match_path(conn, :index))
  end

  def delete_all(conn, _) do
    Repo.delete_all(Match)
    Repo.delete_all(Player)

    conn
    |> put_flash(:info, "All matches deleted successfully.")
    |> redirect(to: match_path(conn, :index))
  end
end
