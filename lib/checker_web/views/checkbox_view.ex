defmodule CheckerWeb.CheckboxView do
  use CheckerWeb, :view
  alias CheckerWeb.CheckboxView

  def render("index.json", %{checkboxes: checkboxes}) do
    %{data: render_many(checkboxes, CheckboxView, "checkbox.json")}
  end

  def render("show.json", %{checkbox: checkbox}) do
    %{data: render_one(checkbox, CheckboxView, "checkbox.json")}
  end

  def render("checkbox.json", %{checkbox: checkbox}) do
    %{id: checkbox.id,
      description: checkbox.description,
      checked: checkbox.checked,
      id: checkbox.id,
      saved: true,
      editing: false,
      editString: ""
    }
  end
end
