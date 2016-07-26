defmodule Dotes.Repo.Migrations.CreateRoll do
  use Ecto.Migration

  def change do
    create table(:rolls) do
      add :number, :integer
      add :eligible_user_ids, {:array, :integer}
      add :immune_user_ids, {:array, :integer}

      timestamps()
    end

  end
end
