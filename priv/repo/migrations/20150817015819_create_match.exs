defmodule DotaQuantify.Repo.Migrations.CreateMatch do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :match_id, :string

      timestamps
    end

  end
end
