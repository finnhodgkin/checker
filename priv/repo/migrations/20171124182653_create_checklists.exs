defmodule Checker.Repo.Migrations.CreateChecklists do
  use Ecto.Migration

  def change do
    create table(:checklists) do
      add :title, :string

      timestamps()
    end

  end
end
