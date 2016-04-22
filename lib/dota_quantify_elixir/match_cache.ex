defmodule Dotes.MatchCache do
  alias Dotes.Repo
  require Ecto.Query
  use GenServer

  @name :match_table
  
  # Key on match_id, store {id, status}

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add(match_id) do
    GenServer.cast(__MODULE__, {:add, match_id})
  end

  def update(match_id, id, status) do
    GenServer.cast(__MODULE__, {:update, match_id, id, status})
  end

  def get(match_id) do
    GenServer.call(__MODULE__, {:get, match_id})
  end

  def remove(match_id) do
    GenServer.cast(__MODULE__, {:remove, match_id})
  end

  def clear() do
    GenServer.cast(__MODULE__, :clear)
  end

  ## Server Callbacks

  def init(:ok) do
    table = :ets.new(@name, [:set, :protected])
    users = Dotes.Match
    |> Ecto.Query.select([m], {m.match_id, m.id})
    |> Repo.all
    |> Enum.each(fn {match_id, id} -> :ets.insert(table, { match_id, {id, :success} }) end)
    {:ok, table}
  end

  def handle_cast({:add, match_id}, table) do
    :ets.insert(table, {match_id, {nil, :pending}})
    {:noreply, table}
  end

  def handle_cast({:update, match_id, id, status}, table) do
    :ets.insert(table, {match_id, {id, status}})
    {:noreply, table}
  end

  def handle_call({:get, match_id}, _from, table) do
    case :ets.lookup(table, match_id) do
      [{^match_id, {id, status}}] -> {:reply, {:ok, id, status}, table}
      [] -> {:reply, :none, table}
    end
  end

  def handle_cast({:remove, match_id}, table) do
    :ets.delete(table, match_id)
    {:noreply, table}
  end

  def handle_cast(:clear, table) do
    :ets.delete_all_objects(table)
    {:noreply, table}
  end

end
