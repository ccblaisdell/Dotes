defmodule DotaQuantify.MatchController do
  use DotaQuantify.Web, :controller

  alias DotaQuantify.Match

  plug :scrub_params, "match" when action in [:create, :update]

  def index(conn, _params) do
    matches = Repo.all(Match)
    render(conn, "index.html", matches: matches)
  end

  def new(conn, _params) do
    changeset = Match.changeset(%Match{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"match" => %{"match_id" => match_id}}) do
    {:ok, match_params} = DotaApi.match(match_id)
    changeset = Match.changeset(%Match{}, match_params)

    case Repo.insert(changeset) do
      {:ok, _match} ->
        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: match_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, match_params: match_params)
    end
  end

  def show(conn, %{"id" => id}) do
    match = Match |> Repo.get!(id) |> Repo.preload [:players]
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
end
