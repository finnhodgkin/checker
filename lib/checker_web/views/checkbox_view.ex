defmodule CheckerWeb.CheckboxView do
  use CheckerWeb, :view
  alias CheckerWeb.CheckboxView

  def render("index.json", %{checkboxes: checkboxes}) do
    %{data: render_many(checkboxes, CheckboxView, "checkbox.json")}
  end

  def render("show.json", %{checkbox: checkbox, animate: animate}) do
    checkboxUpdated = Map.put(checkbox, :animate, animate)
    %{data: render_one(checkboxUpdated, CheckboxView, "checkbox.json")}
  end

  def render("show.json", %{checkbox: checkbox}) do
    %{data: render_one(checkbox, CheckboxView, "checkbox.json")}
  end

  def render("nothing.json", _nothing) do
    %{error: "nothing"}
  end

  def render("checkbox.json", %{checkbox: checkbox}) do
    animate = Map.get(checkbox, :animate)

    %{id: checkbox.id,
      description: checkbox.description,
      checked: checkbox.checked,
      id: checkbox.id,
      saved: true,
      editing: true,
      animate: animate || "noanimation"
    }
  end
end
