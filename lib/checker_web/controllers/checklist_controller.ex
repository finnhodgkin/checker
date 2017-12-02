defmodule CheckerWeb.ChecklistController do
  use CheckerWeb, :controller

  alias Checker.Checklists
  alias Checker.Checklists.Checklist

  action_fallback CheckerWeb.FallbackController

  plug :authenticate when action in [:create, :update, :delete, :index, :show]

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

  def index(conn, _params) do
    checklists = Checklists.list_checklists(conn.assigns.user.id)
    render(conn, "index.json", checklists: checklists)
  end

  def create(conn, %{"checklist" => checklist_params} = params) do
    check_params = checklist_params |> Map.put("user_id", conn.assigns.user.id)
    with {:ok, %Checklist{} = checklist} <- Checklists.create_checklist(check_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", checklist_path(conn, :show, checklist))
      |> render("show.json", checklist: checklist)
    end
  end

  def show(conn, %{"id" => id}) do
    checklist = Checklists.get_checklist!(id)
    cond do
      checklist.user_id == conn.assigns.user.id ->
        render(conn, "show.json", checklist: checklist)
      true ->
        send_resp(conn, :no_content, "")
    end
  end

  def update(conn, %{"id" => id, "checklist" => checklist_params}) do
    checklist = Checklists.get_checklist!(id)
    if checklist.user_id == conn.assigns.user.id do
      with {:ok, %Checklist{} = checklist} <- Checklists.update_checklist(checklist, checklist_params) do
        render(conn, "show.json", checklist: checklist)
      end
    else
      send_resp(conn, :no_content, "")
    end
  end

  def delete(conn, %{"id" => id}) do
    checklist = Checklists.get_checklist!(id)
    if checklist.user_id == conn.assigns.user.id do
      with {:ok, %Checklist{}} <- Checklists.delete_checklist(checklist) do
        send_resp(conn, :no_content, "")
      end
    else
      send_resp(conn, :no_content, "")
    end

  end
end
