defmodule DotaQuantify.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :account_id, :bigint
      add :assists, :integer
      add :deaths, :integer
      add :gold, :integer
      add :denies, :integer
      add :gold_per_min, :integer
      add :gold_spent, :integer
      add :hero_damage, :integer
      add :hero_healing, :integer
      add :hero_id, :integer
      add :item_0, :integer
      add :item_1, :integer
      add :item_2, :integer
      add :item_3, :integer
      add :item_4, :integer
      add :item_5, :integer
      add :kills, :integer
      add :last_hits, :integer
      add :leaver_status, :integer
      add :level, :integer
      add :player_slot, :integer
      add :tower_damage, :integer
      add :xp_per_min, :integer
      add :match_id, :integer
    end

  end
end
