defmodule Dotes.RollTest do
  use Dotes.ModelCase

  alias Dotes.Roll

  @valid_attrs %{number: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Roll.changeset(%Roll{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Roll.changeset(%Roll{}, @invalid_attrs)
    refute changeset.valid?
  end
end
