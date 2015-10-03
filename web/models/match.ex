defmodule DotaQuantify.Match do
  use DotaQuantify.Web, :model
  alias DotaQuantify.Utils
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

    has_many :players, DotaQuantify.Player, on_delete: :delete_all
  end

  @required_fields ~w(start_time lobby_type game_mode duration
                      first_blood_time tower_status_dire tower_status_radiant
                      barracks_status_dire barracks_status_radiant
                      human_players id)
  @optional_fields ~w(seq_num season positive_votes negative_votes
                      cluster league_id radiant_win)

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
    history = DotaApi.history(id)

    case history do
      {:error, reason} -> {:error, reason}

      {:ok, %{"matches" => summaries}} ->
        # Pipe.pipe_with summaries
        summaries
        |> Enum.map(&Map.fetch(&1, "match_id"))
        |> Enum.map(fn {:ok, id} -> async_match(id) end)
        |> Enum.map(&await_match/1)
        |> Enum.map(&DotaQuantify.MatchController.create_match/1)

        {:ok, length(summaries)}
    end

  end

  def get_all_for_user(id) do
    ids = DotaApi.match_ids_stream_dotabuff(id)
    |> Stream.concat
    |> Stream.map(&async_match/1)
    |> Stream.map(&await_match/1)
    |> Stream.map(&DotaQuantify.MatchController.create_match/1)
    |> Enum.to_list
    |> Enum.filter

    length(ids)
  end

  defp async_match(id) do
    Logger.debug "Fetching match ##{id}"
    Task.async(fn -> DotaApi.match(id) end)
  end

  defp await_match(task) do
    Task.await(task) |> handle_match
  end

  defp handle_match({:ok, details}), do: details
  defp handle_match({:error, reason}), do: {:error, reason}
end
