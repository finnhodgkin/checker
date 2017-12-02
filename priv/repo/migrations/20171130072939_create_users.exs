defmodule Checker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :fb_id, :string

      timestamps()
    end

    create unique_index(:users, [:fb_id])
  end
end
