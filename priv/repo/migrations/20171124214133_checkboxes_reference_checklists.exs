defmodule Checker.Repo.Migrations.CheckboxesReferenceChecklists do
  use Ecto.Migration

  def change do
    alter table(:checkboxes) do
      add :checklist_id, references(:checklists, on_delete: :delete_all)
    end
  end
end
