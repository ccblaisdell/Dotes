defmodule Dotes.Player do
  use Dotes.Web, :model

  schema "players" do
    field :account_id, :integer # TODO: Change to string
    field :assists, :integer
    field :deaths, :integer
    field :gold, :integer
    field :denies, :integer
    field :gold_per_min, :integer
    field :gold_spent, :integer
    field :hero_damage, :integer
    field :hero_healing, :integer
    field :hero_id, :integer
    field :item_0, :integer
    field :item_1, :integer
    field :item_2, :integer
    field :item_3, :integer
    field :item_4, :integer
    field :item_5, :integer
    field :kills, :integer
    field :last_hits, :integer
    field :leaver_status, :integer
    field :level, :integer
    field :player_slot, :integer
    field :tower_damage, :integer
    field :xp_per_min, :integer

    belongs_to :match, Dotes.Match
    belongs_to :user, Dotes.User
  end

  @required_fields ~w(account_id assists deaths denies gold_per_min hero_id item_0 item_1 item_2 item_3 item_4 item_5 kills last_hits leaver_status level player_slot xp_per_min match_id)
  # Some fields are no longer included in very old matches
  @optional_fields ~w(user_id gold gold_spent hero_damage hero_healing tower_damage)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> link_user
  end

  def link_user(%{valid?: false} = changeset), do: changeset
  def link_user(changeset) do
    case Dotes.UserCache.get(changeset.changes.account_id) do
      {:ok, user} ->
        put_change(changeset, :user_id, user.id)
      _ ->
        changeset
    end
  end

  def radiant?(player) do
    player.player_slot < 128
  end

  def won?(player, match) do
    radiant?(player) == match.radiant_win
  end
  
  def team(player) do
    if radiant?(player), do: :radiant, else: :dire
  end

  def radiant_team(players) do
    Enum.filter(players, fn p -> radiant?(p) end)
    |> Enum.sort(&by_slot(&1, &2))
  end

  def dire_team(players) do
    Enum.filter(players, fn p -> !radiant?(p) end)
    |> Enum.sort(&by_slot(&1, &2))
  end

  def cached?(player) do
    !!player.user_id
  end

  def by_slot(p1, p2) do
    p1.player_slot < p2.player_slot
  end
end
