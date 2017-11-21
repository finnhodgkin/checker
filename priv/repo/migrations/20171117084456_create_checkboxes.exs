defmodule Checker.Repo.Migrations.CreateCheckboxes do
  use Ecto.Migration

  def change do
    create table(:checkboxes) do
      add :description, :string
      add :checked, :boolean, default: false, null: false

      timestamps()
    end

  end
end
