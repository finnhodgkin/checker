defmodule Checker.CheckboxesTest do
  use Checker.DataCase

  alias Checker.Checkboxes

  describe "checkboxes" do
    alias Checker.Checkboxes.Checkbox

    @valid_attrs %{checked: true, description: "some description", id: 42}
    @update_attrs %{checked: false, description: "some updated description", id: 43}
    @invalid_attrs %{checked: nil, description: nil, id: nil}

    def checkbox_fixture(attrs \\ %{}) do
      {:ok, checkbox} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Checkboxes.create_checkbox()

      checkbox
    end

    test "list_checkboxes/0 returns all checkboxes" do
      checkbox = checkbox_fixture()
      assert Checkboxes.list_checkboxes() == [checkbox]
    end

    test "get_checkbox!/1 returns the checkbox with given id" do
      checkbox = checkbox_fixture()
      assert Checkboxes.get_checkbox!(checkbox.id) == checkbox
    end

    test "create_checkbox/1 with valid data creates a checkbox" do
      assert {:ok, %Checkbox{} = checkbox} = Checkboxes.create_checkbox(@valid_attrs)
      assert checkbox.checked == true
      assert checkbox.description == "some description"
      assert checkbox.id == 42
    end

    test "create_checkbox/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checkboxes.create_checkbox(@invalid_attrs)
    end

    test "update_checkbox/2 with valid data updates the checkbox" do
      checkbox = checkbox_fixture()
      assert {:ok, checkbox} = Checkboxes.update_checkbox(checkbox, @update_attrs)
      assert %Checkbox{} = checkbox
      assert checkbox.checked == false
      assert checkbox.description == "some updated description"
      assert checkbox.id == 43
    end

    test "update_checkbox/2 with invalid data returns error changeset" do
      checkbox = checkbox_fixture()
      assert {:error, %Ecto.Changeset{}} = Checkboxes.update_checkbox(checkbox, @invalid_attrs)
      assert checkbox == Checkboxes.get_checkbox!(checkbox.id)
    end

    test "delete_checkbox/1 deletes the checkbox" do
      checkbox = checkbox_fixture()
      assert {:ok, %Checkbox{}} = Checkboxes.delete_checkbox(checkbox)
      assert_raise Ecto.NoResultsError, fn -> Checkboxes.get_checkbox!(checkbox.id) end
    end

    test "change_checkbox/1 returns a checkbox changeset" do
      checkbox = checkbox_fixture()
      assert %Ecto.Changeset{} = Checkboxes.change_checkbox(checkbox)
    end
  end
end
