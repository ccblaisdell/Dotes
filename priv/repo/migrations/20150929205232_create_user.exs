defmodule Dotes.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :avatar, :string
      add :avatarfull, :string
      add :avatarmedium, :string
      add :communityvisibility, :integer
      add :lastlogoff, :integer
      add :loccountrycode, :string
      add :locstatecode, :string
      add :personaname, :string
      add :personastate, :integer
      add :personastateflags, :integer
      add :primaryclanid, :bigint
      add :profilestate, :integer
      add :profileurl, :string
      add :realname, :string
      add :steamid, :bigint
      add :timecreated, :integer
    end

    alter table(:players) do
      add :user_id, :integer
    end
  end
end
