defmodule Checker.Checkboxes.Checkbox do
  use Ecto.Schema
  import Ecto.Changeset
  alias Checker.Checkboxes.Checkbox


  schema "checkboxes" do
    field :checked, :boolean, default: false
    field :description, :string
    belongs_to :checklist, Checker.Checklists.Checklist

    timestamps()
  end

  @doc false
  def changeset(%Checkbox{} = checkbox, attrs) do
    checkbox
    |> cast(attrs, [:description, :checked, :checklist_id])
    |> validate_required([:description, :checked, :checklist_id])
  end
end
