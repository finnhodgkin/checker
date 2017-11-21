defmodule CheckerWeb.CheckboxController do
  use CheckerWeb, :controller

  alias Checker.Checkboxes
  alias Checker.Checkboxes.Checkbox

  action_fallback CheckerWeb.FallbackController

  def index(conn, _params) do
    checkboxes = Checkboxes.list_checkboxes()
    render(conn, "index.json", checkboxes: checkboxes)
  end

  def create(conn, %{"checkbox" => checkbox_params}) do
    with {:ok, %Checkbox{} = checkbox} <- Checkboxes.create_checkbox(checkbox_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", checkbox_path(conn, :show, checkbox))
      |> render("show.json", checkbox: checkbox)
    end
  end

  def show(conn, %{"id" => id}) do
    checkbox = Checkboxes.get_checkbox!(id)
    render(conn, "show.json", checkbox: checkbox)
  end

  def update(conn, %{"id" => id, "checkbox" => checkbox_params}) do
    checkbox = Checkboxes.get_checkbox!(id)

    with {:ok, %Checkbox{} = checkbox} <- Checkboxes.update_checkbox(checkbox, checkbox_params) do
      render(conn, "show.json", checkbox: checkbox)
    end
  end

  def delete(conn, %{"id" => id}) do
    checkbox = Checkboxes.get_checkbox!(id)
    with {:ok, %Checkbox{}} <- Checkboxes.delete_checkbox(checkbox) do
      send_resp(conn, :no_content, "")
    end
  end
end
