defmodule Dotes.Match do
  use Dotes.Web, :model
  alias Dotes.Utils
  alias Dotes.MatchCache
  require Logger

  schema "matches" do
    field :match_id, :string
    field :seq_num, :integer # TODO: Change to string
    field :start_time, :integer
    field :lobby_type, :integer
    field :game_mode, :integer
    field :radiant_win, :boolean
    field :duration, :integer

    field :first_blood_time, :integer
    field :tower_status_dire, :integer
    field :tower_status_radiant, :integer
    field :barracks_status_dire, :integer
    field :barracks_status_radiant, :integer

    field :season, :integer
    field :human_players, :integer
    field :positive_votes, :integer
    field :negative_votes, :integer
    field :cluster, :integer
    field :league_id, :integer

    has_many :players, Dotes.Player, on_delete: :delete_all
  end

  @required_fields ~w(start_time lobby_type game_mode duration
                      first_blood_time tower_status_dire tower_status_radiant
                      barracks_status_dire barracks_status_radiant
                      human_players match_id)
  @optional_fields ~w(seq_num season positive_votes negative_votes
                      cluster league_id radiant_win)


  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    if params != :empty do
      params = Map.update!(params, "match_id", &to_string/1)
    end
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:match_id)
  end

  @doc """
  Gets recent matches for a user via the steam API
  """
  def get_for_user(user_id) do
    {:ok, %{personaname: name}} = Dotes.UserCache.get(user_id)
    Logger.debug "Get match history for #{name}"
    history = Dota.history(user_id)

    case history do
      {:error, {:ok, response}} -> 
        Logger.error "Match history unavailable for #{name}. #{inspect(response)}}"
        {:error, response}

      {:error, reason} -> {:error, reason}
      
      {:ok, %{"matches" => summaries}} ->
        matches = summaries
        |> Enum.map(&Map.fetch(&1, "match_id"))
        |> Enum.map(fn {:ok, match_id} -> match_id end)
        |> Enum.map(&async_match/1)
        |> Enum.map(&await_match/1)

        {:ok, get_match_fetched_status_counts(matches)}
    end

  end

  defp get_match_fetched_status_counts(matches) do
    skipped = length Enum.filter(matches, fn m -> m == false end)
    failed = length Enum.filter(matches, fn
      {:error, reason} -> true
      %Ecto.Changeset{} = changeset -> !changeset.valid?
      _ -> false
    end)
    succeeded = length(matches) - skipped - failed
    %{succeeded: succeeded, skipped: skipped, failed: failed}
  end

  @doc """
  Gets all matches for a user by scraping dotabuff for match_ids and then 
  requesting match details from the steam API.
  """
  def get_all_for_user(user_id) do
    match_ids = Dota.Dotabuff.match_ids_stream(user_id)
    |> Stream.concat
    |> Stream.map(&async_match/1)
    |> Stream.map(&await_match/1)
    |> Enum.to_list
    |> Enum.filter(&(&1))

    {:ok, length(match_ids)}
  end

  # Will return either
  # {:error, "Already exists"}, if the match has been previously fetched
  # task, the asynchronous function wrapping Dota.match(match_id)
  defp async_match(match_id) do
    case should_get_match?(match_id) do
      {:ok, ^match_id} -> Task.async(fn -> Dota.match(match_id) end)
      error -> error
    end
  end
  
  # TODO: Use this in various places to check if we should get a match?
  def should_get_match?(match_id) do
    case MatchCache.get(match_id) do
      {:ok, _id, :success} ->
        Logger.debug "Skipping match #{match_id}"
        {:error, :fetched, "Match #{match_id} has already been fetched"}
      _ ->
        Logger.debug "Fetching match #{match_id}"
        MatchCache.add(match_id)
        {:ok, match_id}
    end
  end

  # If we skipped the match bc we previously fetched it
  defp await_match({:error, _reason}), do: false
  # Catch the async task and wait for it to finish. Pass it to handle_match when done
  defp await_match(task) do
    Task.await(task, 10_000) |> handle_match
  end

  # If Dota.match(match_id) found the match, create it and return whatever
  # Dotes.MatchController returns
  defp handle_match({:ok, details}) do
    do_create(details)
  end
  # Otherwise return an error tuple
  defp handle_match({:error, reason}), do: {:error, reason}
  
  def create(match_id) do
    case should_get_match?(match_id) do
      {:ok, ^match_id} -> fetch(match_id)
      error -> error
    end
  end
  
  def fetch(match_id) do
    result = case Dota.match(match_id) do
      {:ok, match_params} -> do_create(match_params)
      {:error, reason} -> {:error, :no_match, reason}
    end
  end
  
  def do_create({:error, _reason}), do: nil
  def do_create(match_params) do
    c = changeset(%Dotes.Match{}, match_params)
    result = Repo.insert(c)
    case result do
      {:ok, match} ->
        memorize(match)
        insert_players(match, match_params["players"])
        {:ok, match}
      _ -> 
        Logger.error("Match #{match_params["match_id"]} is invalid")
        {:error, c}
    end
    result
  end
  
  defp insert_players(match, players) do
    player_changesets = Enum.map players, fn player ->
      match |> build_assoc(:players) |> Player.changeset(player)
    end
    case Enum.all?(player_changesets, fn pc -> pc.valid? end) do
      true ->
        Enum.each(player_changesets, fn pc -> Repo.insert(pc) end)
      _ ->
        Logger.error("Match #{match.match_id}: not all players are valid")
        forget(match.match_id)
        Repo.delete(match)
    end
  end

  def memorize(match) do
    MatchCache.update(match.match_id, match.id, :success)
  end

  def forget(match_id) do
    MatchCache.remove(match_id)
  end

  def end_time(match) do
    match.start_time + match.duration
  end
end

defimpl Phoenix.Param, for: Dotes.Match do
  def to_param(%{match_id: match_id}), do: "#{match_id}"
end