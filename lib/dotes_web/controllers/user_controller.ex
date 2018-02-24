defmodule DotesWeb.UserController do
  use Dotes.Web, :controller
  require Logger

  alias Dotes.User
  alias Dotes.Player
  alias Dotes.PaginationView

  plug :scrub_params, "user" when action in [:create, :update]
  
  # TODO
  # def update_avatar(conn, %{"id" => id})

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"dotaid" => dotaid} = user_params}) do
    {:ok, api_params} = dotaid |> Dota.dota_to_steam_id |> Dota.profile
    changeset = User.changeset(%User{}, Map.merge(user_params, api_params))

    case Repo.insert(changeset) do
      {:ok, _user} ->
        User.memorize(changeset.model)
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id} = params) do

    user = Repo.get!(User, id)
    page = Player
    |> where(user_id: ^id)
    |> preload([:match, :user])
    |> Repo.paginate(params)

    pagination_links  = PaginationView.pagination_links(conn, page)
    pagination_window = PaginationView.pagination_window(page)

    render(conn, "show.html", user: user, players: page.entries, 
                              page_number: page.page_number, page_size: page.page_size, 
                              total_pages: page.total_pages, total_entries: page.total_entries, 
                              pagination_links: pagination_links, pagination_window: pagination_window)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)
    User.forget(id)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  # Get recent matches for this user
  def get(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    case Dotes.Match.get_for_user(user.id) do
      {:ok, match_counts} ->
        conn
        |> Dotes.MatchController.put_flash_match_counts(match_counts)
        |> redirect(to: user_path(conn, :show, user))
      {:error, reason} ->
        conn
        |> put_flash(:info, "Match fetch failed: #{reason}")
        |> redirect(to: user_path(conn, :show, user))
    end

  end

  def get_all(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    
    case Dotes.Match.get_all_for_user(user.id) do
      {:ok, match_counts} ->
        conn
        |> Dotes.MatchController.put_flash_match_counts(match_counts)
        |> redirect(to: user_path(conn, :show, user))
      {:error, reason} ->
        conn
        |> put_flash(:info, "Match fetch failed: #{reason}")
        |> redirect(to: user_path(conn, :show, user))
    end
  end
end
