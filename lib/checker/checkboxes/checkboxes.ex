defmodule Checker.Checkboxes do
  @moduledoc """
  The Checkboxes context.
  """

  import Ecto.Query, warn: false
  alias Checker.Repo

  alias Checker.Checkboxes.Checkbox

  @doc """
  Returns the list of checkboxes.

  ## Examples

      iex> list_checkboxes()
      [%Checkbox{}, ...]

  """
  def list_checkboxes do
    Repo.all(Checkbox)
  end

  @doc """
  Gets a single checkbox.

  Raises `Ecto.NoResultsError` if the Checkbox does not exist.

  ## Examples

      iex> get_checkbox!(123)
      %Checkbox{}

      iex> get_checkbox!(456)
      ** (Ecto.NoResultsError)

  """
  def get_checkbox!(id), do: Repo.get!(Checkbox, id)

  @doc """
  Creates a checkbox.

  ## Examples

      iex> create_checkbox(%{field: value})
      {:ok, %Checkbox{}}

      iex> create_checkbox(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_checkbox(attrs \\ %{}) do
    %Checkbox{}
    |> Checkbox.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a checkbox.

  ## Examples

      iex> update_checkbox(checkbox, %{field: new_value})
      {:ok, %Checkbox{}}

      iex> update_checkbox(checkbox, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_checkbox(%Checkbox{} = checkbox, attrs) do
    checkbox
    |> Checkbox.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Checkbox.

  ## Examples

      iex> delete_checkbox(checkbox)
      {:ok, %Checkbox{}}

      iex> delete_checkbox(checkbox)
      {:error, %Ecto.Changeset{}}

  """
  def delete_checkbox(%Checkbox{} = checkbox) do
    Repo.delete(checkbox)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking checkbox changes.

  ## Examples

      iex> change_checkbox(checkbox)
      %Ecto.Changeset{source: %Checkbox{}}

  """
  def change_checkbox(%Checkbox{} = checkbox) do
    Checkbox.changeset(checkbox, %{})
  end
end
