defmodule Checker.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Checker.Accounts.User


  schema "users" do
    field :name, :string
    field :fb_id, :string
    has_many :checklist, Checker.Checklists.Checklist

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :fb_id])
    |> unique_constraint(:fb_id)
    |> validate_required([:name, :fb_id])
  end
end
