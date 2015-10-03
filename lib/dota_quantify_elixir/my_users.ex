defmodule DotaQuantify.MyUsers do
	alias DotaQuantify.Repo
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

	## Server Callbacks

	def init(:ok) do
		users = DotaQuantify.User 
		|> Repo.all
		|> Enum.map(fn user -> {user.id, %{personaname: user.personaname, avatar: user.avatar, id: user.id}} end)
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

end
