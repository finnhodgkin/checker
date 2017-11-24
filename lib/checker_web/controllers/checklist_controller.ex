defmodule CheckerWeb.ChecklistController do
  use CheckerWeb, :controller

  alias Checker.Checklists
  alias Checker.Checklists.Checklist

  action_fallback CheckerWeb.FallbackController

  def index(conn, _params) do
    checklists = Checklists.list_checklists()
    render(conn, "index.json", checklists: checklists)
  end

  def create(conn, %{"checklist" => checklist_params}) do
    with {:ok, %Checklist{} = checklist} <- Checklists.create_checklist(checklist_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", checklist_path(conn, :show, checklist))
      |> render("show.json", checklist: checklist)
    end
  end

  def show(conn, %{"id" => id}) do
    checklist = Checklists.get_checklist!(id)
    render(conn, "show.json", checklist: checklist)
  end

  def update(conn, %{"id" => id, "checklist" => checklist_params}) do
    checklist = Checklists.get_checklist!(id)

    with {:ok, %Checklist{} = checklist} <- Checklists.update_checklist(checklist, checklist_params) do
      render(conn, "show.json", checklist: checklist)
    end
  end

  def delete(conn, %{"id" => id}) do
    checklist = Checklists.get_checklist!(id)
    with {:ok, %Checklist{}} <- Checklists.delete_checklist(checklist) do
      send_resp(conn, :no_content, "")
    end
  end
end
