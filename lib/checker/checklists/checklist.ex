defmodule Checker.Checklists.Checklist do
  use Ecto.Schema
  import Ecto.Changeset
  alias Checker.Checklists.Checklist


  schema "checklists" do
    field :title, :string
    has_many :checkbox, Checker.Checkboxes.Checkbox

    timestamps()
  end

  @doc false
  def changeset(%Checklist{} = checklist, attrs) do
    checklist
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
