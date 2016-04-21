defmodule Dotes.User do
  use Dotes.Web, :model
  alias Dotes.Utils

  @primary_key {:id, :id, autogenerate: false}

  schema "users" do
    field :avatar, :string
    field :avatarfull, :string
    field :avatarmedium, :string
    field :communityvisibility, :integer
    field :lastlogoff, :integer
    field :loccountrycode, :string
    field :locstatecode, :string
    field :personaname, :string
    field :personastate, :integer
    field :personastateflags, :integer
    field :primaryclanid, :integer
    field :profilestate, :integer
    field :profileurl, :string
    field :realname, :string
    field :steamid, :integer
    field :timecreated, :integer

    has_many :players, Dotes.Player
  end

  @required_fields ~w(avatar avatarfull avatarmedium personaname profileurl steamid id)
  @optional_fields ~w(communityvisibility lastlogoff loccountrycode locstatecode personastate personastateflags primaryclanid profilestate timecreated realname)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    params = Utils.rename_keys(params, %{"dotaid" => "id"})
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:id, name: "users_pkey")
  end

  def memorize(changeset) do
    Dotes.UserCache.add(changeset.model)
  end

  def forget(id) do
    Dotes.UserCache.remove(id)
  end
end
