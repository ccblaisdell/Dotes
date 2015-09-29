defmodule DotaQuantify.Match do
  use DotaQuantify.Web, :model

  schema "matches" do
    field :match_id, :integer
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

  @required_fields ~w(match_id start_time lobby_type game_mode radiant_win duration
                      first_blood_time tower_status_dire tower_status_radiant
                      barracks_status_dire barracks_status_radiant
                      human_players)
  @optional_fields ~w(seq_num season positive_votes negative_votes
                      cluster league_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
