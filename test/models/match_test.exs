defmodule DotaQuantify.MatchTest do
  use DotaQuantify.ModelCase

  alias DotaQuantify.Match

  @valid_attrs %{match_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Match.changeset(%Match{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Match.changeset(%Match{}, @invalid_attrs)
    refute changeset.valid?
  end
end
