defmodule Dotes.UserCache do
  alias Dotes.Repo
  use GenServer

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  def exists?(id) do
    GenServer.call(__MODULE__, {:exists?, id})
  end

  def add(user) do
    GenServer.cast(__MODULE__, {:add, user})
  end

  def remove(id) do
    GenServer.call(__MODULE__, {:remove, id})
  end

  ## Server Callbacks

  def init(:ok) do
    users = Dotes.User 
    |> Repo.all
    |> Enum.map(fn user -> {user.id, user_fields(user)} end)
    |> Enum.into(%{})
    {:ok, users}
  end

  def handle_call(:all, _from, users) do
    {:reply, {:ok, users}, users}
  end

  def handle_call({:get, id}, _from, users) do
    case Map.fetch(users, id) do
      {:ok, user} -> {:reply, {:ok, user}, users}
      _ -> {:reply, {:error}, users}
    end
  end

  def handle_call({:exists?, id}, _from, users) do
    case Map.fetch(users, id) do
      {:ok, _user} -> {:reply, {:ok, true}, users}
      _ -> {:reply, {:ok, false}, users}
    end
  end

  def handle_cast({:add, user}, users) do
    users = Map.put(users, user.id, user_fields(user))
    {:noreply, users}
  end

  defp user_fields(%Dotes.User{personaname: personaname, avatar: avatar, id: id}) do
    %{personaname: personaname, avatar: avatar, id: id}
  end

  def handle_call({:remove, id}, _from, users) do
    user = Map.get(users, id)
    users = Map.delete(users, id)
    {:reply, {:ok, user}, users}
  end

end
