defmodule Dotes.Repo.Migrations.AddMatchFields do
  use Ecto.Migration

  def change do
  	alter table(:matches) do
      add :seq_num, :integer
      add :start_time, :integer
      add :lobby_type, :integer
      add :game_mode, :integer
      add :radiant_win, :boolean
      add :duration, :integer

      add :first_blood_time, :integer
      add :tower_status_dire, :integer
      add :tower_status_radiant, :integer
      add :barracks_status_dire, :integer
      add :barracks_status_radiant, :integer

      add :season, :integer
      add :human_players, :integer
      add :positive_votes, :integer
      add :negative_votes, :integer
      add :cluster, :integer
      add :league_id, :integer
  	end
  end
end
