defmodule DotaQuantify.Repo.Migrations.AddMatchFields do
  use Ecto.Migration

  def change do
  	alter table(:matches) do
      add :seq_num, :integer
      add :start, :time
      add :lobby, :string
      add :mode, :string
      add :winner, :string
      add :duration, :integer

      add :first_blood, :integer
      add :dire_tower_status, :integer
      add :radiant_tower_status, :integer
      add :dire_barracks_status, :integer
      add :radiant_barracks_status, :integer

      add :season, :integer
      add :human_players, :integer
      add :positive_votes, :integer
      add :negative_votes, :integer
      add :cluster, :integer
      add :league_id, :integer

      add :won, :boolean
  	end
  end
end
