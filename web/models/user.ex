defmodule DotaQuantify.User do
  use DotaQuantify.Web, :model

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
    field :dotaid, :integer

    has_many :players, DotaQuantify.Player
  end

  @required_fields ~w(avatar avatarfull avatarmedium personaname profileurl steamid dotaid)
  @optional_fields ~w(communityvisibility lastlogoff loccountrycode locstatecode personastate personastateflags primaryclanid profilestate timecreated realname)

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
