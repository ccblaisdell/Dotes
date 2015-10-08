defmodule Dotes.Match do
  use Dotes.Web, :model
  alias Dotes.Utils
  require Logger

  @primary_key {:id, :id, autogenerate: false}

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
                      human_players id)
  @optional_fields ~w(seq_num season positive_votes negative_votes
                      cluster league_id radiant_win)

  after_insert :memorize_match
  after_delete :forget_match

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    params = Utils.rename_keys(params, %{"match_id" => "id"})
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:id, name: "matches_pkey")
  end

  def get_for_user(id) do
    Logger.debug "Get match history for #{id}"
    history = Dota.history(id)

    case history do
      {:error, reason} -> {:error, reason}

      {:ok, %{"matches" => summaries}} ->
        fetched = summaries
        |> Enum.map(&Map.fetch(&1, "match_id"))
        |> Enum.map(fn {:ok, id} -> id end)
        |> Enum.map(&async_match/1)
        |> Enum.map(&await_match/1)
        |> Enum.map(&Dotes.MatchController.create_match/1)
        |> Enum.filter(&(&1))

        {:ok, length(fetched)}
    end

  end

  def get_all_for_user(id) do
    ids = Dota.Dotabuff.match_ids_stream(id)
    |> Stream.concat
    |> Stream.map(&async_match/1)
    |> Stream.map(&await_match/1)
    |> Stream.map(&Dotes.MatchController.create_match/1)
    |> Enum.to_list
    |> Enum.filter(&(&1))

    length(ids)
  end

  defp async_match(id) do
    case Dotes.MatchCache.get(id) do
      {:ok, :success} ->
        Logger.debug "Skipping match ##{id}"
        {:error, "Already exists"}
      _ ->
        Logger.debug "Fetching match ##{id}"
        Dotes.MatchCache.add(id)
        Task.async(fn -> Dota.match(id) end)
    end
  end

  defp await_match({:error, _reason} = response), do: response
  defp await_match(task) do
    Task.await(task, 10_000) |> handle_match
  end

  defp handle_match({:ok, details}), do: details
  defp handle_match({:error, reason}), do: {:error, reason}

  defp memorize_match(changeset) do
    Dotes.MatchCache.update(changeset.model.id, :success)
    changeset
  end

  defp forget_match(changeset) do
    Dotes.MatchCache.remove(changeset.model.id)
    changeset
  end
end
