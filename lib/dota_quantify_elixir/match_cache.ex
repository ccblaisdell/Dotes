defmodule Dotes.MatchCache do
  alias Dotes.Repo
  require Ecto.Query
  use GenServer

  @name :match_table

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add(id) do
    GenServer.cast(__MODULE__, {:add, id})
  end

  def update(id, status) do
    GenServer.cast(__MODULE__, {:update, id, status})
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  def remove(id) do
    GenServer.cast(__MODULE__, {:remove, id})
  end

  def clear() do
    GenServer.cast(__MODULE__, :clear)
  end

  ## Server Callbacks

  def init(:ok) do
    table = :ets.new(@name, [:set, :protected])
    users = Dotes.Match
    |> Ecto.Query.select([m], m.id)
    |> Repo.all
    |> Enum.each(fn id -> :ets.insert(table, {id, :success}) end)
    {:ok, table}
  end

  def handle_cast({:add, id}, table) do
    :ets.insert(table, {id, :pending})
    {:noreply, table}
  end

  def handle_cast({:update, id, status}, table) do
    :ets.insert(table, {id, status})
    {:noreply, table}
  end

  def handle_call({:get, id}, _from, table) do
    case :ets.lookup(table, id) do
      [{^id, status}] -> {:reply, {:ok, status}, table}
      [] -> {:reply, :none, table}
    end
  end

  def handle_cast({:remove, id}, table) do
    :ets.delete(table, id)
    {:noreply, table}
  end

  def handle_cast(:clear, table) do
    :ets.delete_all_objects(table)
    {:noreply, table}
  end

end
