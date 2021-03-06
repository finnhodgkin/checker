defmodule CheckerWeb.Router do
  use CheckerWeb, :router

  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CheckerWeb.Plugs.Auth
  end

  scope "/", CheckerWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/auth", CheckerWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  scope "/", CheckerWeb do
    pipe_through :api

    resources "/checkboxes", CheckboxController, except: [:new, :edit]
    resources "/checklists", ChecklistController, except: [:new, :edit]
    get "/checklists", ChecklistController, :nothing
  end
end
