defmodule DotaQuantify.Player do
  use DotaQuantify.Web, :model

  schema "players" do
    field :account_id, :integer
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

    belongs_to :match, DotaQuantify.Match
    belongs_to :user, DotaQuantify.User
  end

  @required_fields ~w(account_id assists deaths gold denies gold_per_min gold_spent hero_damage hero_healing hero_id item_0 item_1 item_2 item_3 item_4 item_5 kills last_hits leaver_status level player_slot tower_damage xp_per_min match_id)
  @optional_fields ~w(user_id)

  before_insert :link_user

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def link_user(changeset) do
    case DotaQuantify.MyUsers.get(changeset.model.account_id) do
      {:ok, user} ->
        put_change(changeset, :user_id, user.id)
      _ ->
        changeset
    end
  end
end
