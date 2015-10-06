defmodule Dotes.PlayerTest do
  use Dotes.ModelCase

  alias Dotes.Player

  @valid_attrs %{account_id: 42, assists: 42, deaths: 42, denies: 42, gold: 42, gold_per_min: 42, gold_spent: 42, hero_damage: 42, hero_healing: 42, hero_id: 42, item_0: 42, item_1: 42, item_2: 42, item_3: 42, item_4: 42, item_5: 42, kills: 42, last_hits: 42, leaver_status: 42, level: 42, player_slot: 42, tower_damage: 42, xp_per_min: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Player.changeset(%Player{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Player.changeset(%Player{}, @invalid_attrs)
    refute changeset.valid?
  end
end
