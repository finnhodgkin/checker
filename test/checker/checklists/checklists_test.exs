defmodule Checker.ChecklistsTest do
  use Checker.DataCase

  alias Checker.Checklists

  describe "checklists" do
    alias Checker.Checklists.Checklist

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def checklist_fixture(attrs \\ %{}) do
      {:ok, checklist} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Checklists.create_checklist()

      checklist
    end

    test "list_checklists/0 returns all checklists" do
      checklist = checklist_fixture()
      assert Checklists.list_checklists() == [checklist]
    end

    test "get_checklist!/1 returns the checklist with given id" do
      checklist = checklist_fixture()
      assert Checklists.get_checklist!(checklist.id) == checklist
    end

    test "create_checklist/1 with valid data creates a checklist" do
      assert {:ok, %Checklist{} = checklist} = Checklists.create_checklist(@valid_attrs)
      assert checklist.title == "some title"
    end

    test "create_checklist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checklists.create_checklist(@invalid_attrs)
    end

    test "update_checklist/2 with valid data updates the checklist" do
      checklist = checklist_fixture()
      assert {:ok, checklist} = Checklists.update_checklist(checklist, @update_attrs)
      assert %Checklist{} = checklist
      assert checklist.title == "some updated title"
    end

    test "update_checklist/2 with invalid data returns error changeset" do
      checklist = checklist_fixture()
      assert {:error, %Ecto.Changeset{}} = Checklists.update_checklist(checklist, @invalid_attrs)
      assert checklist == Checklists.get_checklist!(checklist.id)
    end

    test "delete_checklist/1 deletes the checklist" do
      checklist = checklist_fixture()
      assert {:ok, %Checklist{}} = Checklists.delete_checklist(checklist)
      assert_raise Ecto.NoResultsError, fn -> Checklists.get_checklist!(checklist.id) end
    end

    test "change_checklist/1 returns a checklist changeset" do
      checklist = checklist_fixture()
      assert %Ecto.Changeset{} = Checklists.change_checklist(checklist)
    end
  end
end
