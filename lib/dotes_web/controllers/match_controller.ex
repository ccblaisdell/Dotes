defmodule DotesWeb.MatchController do
  use Dotes.Web, :controller

  alias Dotes.Match
  alias Dotes.Player
  alias Dotes.User
  alias Dotes.MatchCache
  alias Dotes.PaginationView

  plug :scrub_params, "match" when action in [:create, :update]

  def index(conn, params) do
    page = Match
    |> order_by([m], desc: m.start_time)
    |> preload([:players, players: :user])
    |> Repo.paginate(params)

    pagination_links = PaginationView.pagination_links(conn, page)
    pagination_window = PaginationView.pagination_window(page)

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
    case Match.create(match_id) do
      {:ok, _match} ->
        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: match_path(conn, :show, match_id))
      {:error, :no_match, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: match_path(conn, :index))
      {:error, :fetched, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: match_path(conn, :show, match_id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => match_id}) do
    {:ok, id, _status} = MatchCache.get(match_id)
    match = Match 
    |> Repo.get!(id) 
    |> Repo.preload([:players, players: :user])

    radiant_team = Player.radiant_team(match.players)
    dire_team = Player.dire_team(match.players)

    render(conn, "show.html", match: match, radiant_team: radiant_team, dire_team: dire_team)
  end

  def edit(conn, %{"id" => match_id}) do
    {:ok, id, _status} = MatchCache.get(match_id)
    match = Repo.get!(Match, id)
    changeset = Match.changeset(match)
    render(conn, "edit.html", match: match, changeset: changeset)
  end

  def update(conn, %{"id" => match_id, "match" => match_params}) do
    {:ok, id, _status} = MatchCache.get(match_id)
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

  def delete(conn, %{"id" => match_id}) do
    {:ok, id, _status} = MatchCache.get(match_id)
    match = Repo.get!(Match, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(match)
    Match.forget(id)

    conn
    |> put_flash(:info, "Match deleted successfully.")
    |> redirect(to: match_path(conn, :index))
  end

  def delete_all(conn, _) do
    Repo.delete_all(Match)
    Repo.delete_all(Player)
    MatchCache.clear()

    conn
    |> put_flash(:info, "All matches deleted successfully.")
    |> redirect(to: match_path(conn, :index))
  end

  def get_recent(conn, _) do
    match_counts = from(u in User)
    |> select([u], u.id)
    |> Repo.all
    |> Enum.map(&async_get_for_user/1)
    |> Enum.map(&await_get_for_user/1)  
    |> Enum.reduce(%{}, &Match.reduce_counts/2)

    conn
    |> put_flash_match_counts(match_counts)
    |> redirect(to: match_path(conn, :index))
  end
  
  def put_flash_match_counts(c, %{succeeded: succeeded, skipped: skipped, failed: failed}) do
    put_flash(c, :info, "Fetched #{succeeded} matches. (#{skipped} skipped and #{failed} failed)")
  end
  def put_flash_match_counts(c, _), do: put_flash(c, :info, "Fetched some matches")

  defp async_get_for_user(id),   do: Task.async(fn -> Match.get_for_user(id) end)
  defp await_get_for_user(task), do: wrap_await_for_user(task) |> handle_get_for_user

  defp wrap_await_for_user(task) do
    Task.await(task, 30_000)
  rescue
    x in [RuntimeError] ->
      {:error, task}
  end

  # TODO: This should take {:ok, [success: s, skipped: sk, failed: f]}
  defp handle_get_for_user({:ok, n}), do: n
  defp handle_get_for_user({:error, _}), do: 0
end
