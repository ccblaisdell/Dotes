defmodule Dotes.Match do
  use Dotes.Web, :model
  alias Dotes.Utils
  alias Dotes.MatchCache
  require Logger
  
  # TODO: figure out how to index on match_id
  # TODO: write migration for new id and match_id fields

  schema "matches" do
    field :seq_num, :integer
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
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:match_id)
  end

  @doc """
  Gets recent matches for a user via the steam API
  """
  def get_for_user(user_id) do
    Logger.debug "Get match history for #{user_id}"
    history = Dota.history(user_id)

    case history do
      {:error, reason} -> {:error, reason}

      {:ok, %{"matches" => summaries}} ->
        fetched = summaries
        |> Enum.map(&Map.fetch(&1, "match_id"))
        |> Enum.map(fn {:ok, match_id} -> match_id end)
        |> Enum.map(&async_match/1)
        |> Enum.map(&await_match/1)
        |> Enum.map(&Dotes.MatchController.create_match/1)
        |> Enum.filter(&(&1))

        {:ok, length(fetched)}
    end

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
    |> Stream.map(&Dotes.MatchController.create_match/1)
    |> Enum.to_list
    |> Enum.filter(&(&1))

    # NOTE: should be a tuple? {:ok, length(match_ids)}
    length(match_ids)
  end

  defp async_match(match_id) do
    case MatchCache.get(match_id) do
      {:ok, _id, :success} ->
        Logger.debug "Skipping match ##{match_id}"
        {:error, "Already exists"}
      _ ->
        Logger.debug "Fetching match ##{match_id}"
        MatchCache.add(match_id)
        Task.async(fn -> Dota.match(match_id) end)
    end
  end

  defp await_match({:error, _reason} = response), do: response
  defp await_match(task) do
    Task.await(task, 10_000) |> handle_match
  end

  defp handle_match({:ok, details}), do: details
  defp handle_match({:error, reason}), do: {:error, reason}

  defp memorize(changeset) do
    MatchCache.update(changeset.model.match_id, changeset.model.id, :success)
    changeset
  end

  defp forget(match_id) do
    MatchCache.remove(match_id)
    changeset
  end

  def end_time(match) do
    match.start_time + match.duration
  end
end

defimpl Phoenix.Param, for: Dotes.Match do
  def to_param(%{match_id: match_id}) do
    "#{match_id}"
  end
end