defmodule Checker.Repo.Migrations.ChecklistUserOwnership do
  use Ecto.Migration

  def change do
    alter table(:checklists) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
