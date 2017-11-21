defmodule Checker.Checkboxes.Checkbox do
  use Ecto.Schema
  import Ecto.Changeset
  alias Checker.Checkboxes.Checkbox


  schema "checkboxes" do
    field :checked, :boolean, default: false
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(%Checkbox{} = checkbox, attrs) do
    checkbox
    |> cast(attrs, [:description, :checked])
    |> validate_required([:description, :checked])
  end
end
