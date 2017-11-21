defmodule CheckerWeb.CheckboxControllerTest do
  use CheckerWeb.ConnCase

  alias Checker.Checkboxes
  alias Checker.Checkboxes.Checkbox

  @create_attrs %{checked: true, description: "some description", id: 42}
  @update_attrs %{checked: false, description: "some updated description", id: 43}
  @invalid_attrs %{checked: nil, description: nil, id: nil}

  def fixture(:checkbox) do
    {:ok, checkbox} = Checkboxes.create_checkbox(@create_attrs)
    checkbox
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all checkboxes", %{conn: conn} do
      conn = get conn, checkbox_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create checkbox" do
    test "renders checkbox when data is valid", %{conn: conn} do
      conn = post conn, checkbox_path(conn, :create), checkbox: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, checkbox_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "checked" => true,
        "description" => "some description",
        "id" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, checkbox_path(conn, :create), checkbox: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update checkbox" do
    setup [:create_checkbox]

    test "renders checkbox when data is valid", %{conn: conn, checkbox: %Checkbox{id: id} = checkbox} do
      conn = put conn, checkbox_path(conn, :update, checkbox), checkbox: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, checkbox_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "checked" => false,
        "description" => "some updated description",
        "id" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, checkbox: checkbox} do
      conn = put conn, checkbox_path(conn, :update, checkbox), checkbox: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete checkbox" do
    setup [:create_checkbox]

    test "deletes chosen checkbox", %{conn: conn, checkbox: checkbox} do
      conn = delete conn, checkbox_path(conn, :delete, checkbox)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, checkbox_path(conn, :show, checkbox)
      end
    end
  end

  defp create_checkbox(_) do
    checkbox = fixture(:checkbox)
    {:ok, checkbox: checkbox}
  end
end
