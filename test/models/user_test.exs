defmodule Dotes.UserTest do
  use Dotes.ModelCase

  alias Dotes.User

  @valid_attrs %{avatar: "some content", avatarfull: "some content", avatarmedium: "some content", communityvisibility: 42, id: 42, lastlogoff: 42, loccountrycode: "some content", locstatecode: "some content", personaname: "some content", personastate: 42, personastateflags: 42, primaryclanid: 42, profilestate: 42, profileurl: "some content", realname: "some content", steamid: 42, timecreated: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
