defmodule CheckerWeb.CheckboxController do
  use CheckerWeb, :controller

  alias Checker.Checkboxes
  alias Checker.Checkboxes.Checkbox
  alias Checker.Checklists

  action_fallback CheckerWeb.FallbackController

  plug :authenticate when action in [:create, :update, :delete, :index]

  defp authenticate(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> redirect(to: checklist_path(conn, :nothing))
      |> halt()
    end
  end

  def nothing(conn, _params) do
    render(conn, "nothing.json", "nothing")
  end

  def index(conn, %{"id" => id}) do
    checklist = Checklists.get_checklist!(id)
    cond do
      checklist.user_id == conn.assigns.user.id ->
        checkboxes = Checkboxes.list_checkboxes(id)
        render(conn, "index.json", checkboxes: checkboxes)
      true ->
        send_resp(conn, :no_content, "")
    end
  end

  def create(conn, %{"checkbox" => checkbox_params}) do
    %{"checklist_id" => id} = checkbox_params
    case checklistOwnership(id, conn.assigns.user.id) do
      nil ->
        send_resp(conn, :no_content, "")
      _checklist ->
        with {:ok, %Checkbox{} = checkbox} <- Checkboxes.create_checkbox(checkbox_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", checkbox_path(conn, :show, checkbox))
          |> render("show.json", checkbox: checkbox)
        end
    end
  end

  def update(conn, %{"id" => id, "checkbox" => checkbox_params}) do
    case checkboxOwnership(id, conn.assigns.user.id) do
      nil ->
        send_resp(conn, :no_content, "")
      checkbox ->
        with {:ok, %Checkbox{} = checkbox} <- Checkboxes.update_checkbox(checkbox, checkbox_params) do
          render(conn, "show.json", checkbox: checkbox)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case checkboxOwnership(id, conn.assigns.user.id) do
      nil ->
        send_resp(conn, :no_content, "")
      checkbox ->
        Checkboxes.delete_checkbox(checkbox)
        send_resp(conn, :no_content, "")
    end
  end

  defp addAnimation(checkbox, animation_name) do
    checkbox
    |> Map.put(:animate, animation_name)
  end

  defp checklistOwnership(id, user_id) do
    checklist = Checklists.get_checklist!(id)

    checklist.user_id == user_id && checklist || nil
  end

  defp checkboxOwnership(id, user_id) do
    checkbox = Checkboxes.get_checkbox!(id)

    checklistOwnership(checkbox.checklist_id, user_id) && checkbox || nil
  end
end
