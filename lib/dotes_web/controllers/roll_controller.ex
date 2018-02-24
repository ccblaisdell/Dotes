defmodule DotesWeb.RollController do
  use Dotes.Web, :controller

  alias Dotes.Roll

  def index(conn, _params) do
    {rolls, users} = get_index_data
    changeset = Roll.changeset(%Roll{})
    
    render(conn, "index.html", rolls: rolls, users: users, changeset: changeset)
  end
  
  def create(conn, %{"roll" => %{"eligibility" => eligibility}}) do
    eligible_counts = get_eligibility_counts(eligibility)
    
    if length(eligible_counts.eligible) + length(eligible_counts.immune) < 6 || length(eligible_counts.eligible) < 1 do
      
      {rolls, users} = get_index_data
      changeset = Roll.changeset(%Roll{}, %{
        eligible_user_ids: eligible_counts.eligible,
        immune_user_ids: eligible_counts.immune })
        
      conn
      |> put_flash(:info, "Must be at least 6 present, and 1 eligible")
      |> render("index.html", changeset: changeset, rolls: rolls, users: users)
      
    else
      
      {number, user_id, user} = roll(eligible_counts.eligible)
      changeset = Roll.changeset(%Roll{}, %{ number: number, 
        eligible_user_ids: eligible_counts.eligible,
        immune_user_ids: eligible_counts.immune })
      
      case Repo.insert(changeset) do
        {:ok, _roll} ->
          conn
          |> put_flash(:info, "Rolled #{number} (#{user.personaname})")
          |> redirect(to: roll_path(conn, :index))
        {:error, changeset} ->
          {rolls, users} = get_index_data
          render(conn, "index.html", changeset: changeset, rolls: rolls, users: users)
      end
      
    end
  
  end
  
  defp get_index_data do
    rolls = Roll |> order_by([r], desc: r.inserted_at) |> Repo.all
    users = Dotes.UserCache.all |> elem(1) |> Map.values
    {rolls, users}
  end
  
  defp get_eligibility_counts(eligibility) do
    eligibility 
    |> Map.to_list() 
    |> Enum.reduce(
      %{eligible: [], immune: [], absent: []}, 
      fn ({id, eli}, acc) ->
        Map.update!(acc, String.to_atom(eli), fn (list) -> 
          [ String.to_integer(id) | list ] 
        end)
      end)
  end
  
  defp roll(user_ids) do
    range = 1..Enum.count(user_ids)
    number = Enum.random(range)
    user_id = Enum.at(user_ids, number-1)
    {:ok, user} = Dotes.UserCache.get(user_id)
    {number, user_id, user}
  end

  def show(conn, %{"id" => id}) do
    roll = Repo.get!(Roll, id)
    render(conn, "show.html", roll: roll)
  end

  def edit(conn, %{"id" => id}) do
    roll = Repo.get!(Roll, id)
    changeset = Roll.changeset(roll)
    render(conn, "edit.html", roll: roll, changeset: changeset)
  end

  def update(conn, %{"id" => id, "roll" => roll_params}) do
    roll = Repo.get!(Roll, id)
    changeset = Roll.changeset(roll, roll_params)

    case Repo.update(changeset) do
      {:ok, roll} ->
        conn
        |> put_flash(:info, "Roll updated successfully.")
        |> redirect(to: roll_path(conn, :show, roll))
      {:error, changeset} ->
        render(conn, "edit.html", roll: roll, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    roll = Repo.get!(Roll, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(roll)

    conn
    |> put_flash(:info, "Roll deleted successfully.")
    |> redirect(to: roll_path(conn, :index))
  end
end
