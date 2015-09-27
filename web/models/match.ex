defmodule DotaQuantify.Match do
  use DotaQuantify.Web, :model

  schema "matches" do
    field :match_id, :string

    timestamps
  end

  @required_fields ~w(match_id)
  @optional_fields ~w()

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
