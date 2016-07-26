defmodule Dotes.Roll do
  use Dotes.Web, :model
  alias Dotes.UserCache

  schema "rolls" do
    field :number, :integer
    field :eligible_user_ids, {:array, :integer}
    field :immune_user_ids, {:array, :integer}

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number, :eligible_user_ids, :immune_user_ids])
    |> validate_required([:number])
  end
  
  def get_user_id(roll) do
    roll.eligible_user_ids
    |> Enum.at(roll.number-1)
  end
  
  def get_user(roll) do
    get_user_id(roll)
    |> UserCache.get
    |> elem(1)
  end
end
