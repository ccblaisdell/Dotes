defmodule Dotes.Repo.Migrations.RemoveMatchIdFromPrimaryKey do
  use Ecto.Migration
  
  # Up until this point, we have used the match_id as the primary key, with the
  # field name id. We are moving the match_id to its own column and storing it
  # as a string.

  def change do
    alter table(:matches) do
      add :match_id, :string
    end
    create index(:matches, [:match_id], unique: true)
  end
end
