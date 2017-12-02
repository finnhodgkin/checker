defmodule CheckerWeb.AuthController do
  use CheckerWeb, :controller

  plug Ueberauth
  use Guardian, otp_app: :checker
  alias Checker.Accounts

  def callback(%{assigns: %{ueberauth_auth: %{extra: %{raw_info: %{user: %{"id" => id, "name" => name}}}}}} = conn, _params) do
    {:ok, token, _claims} = Checker.Guardian.encode_and_sign(id)

    case create_or_set_user(name, id) do
      {:error, _error} ->
        conn
      {:ok, user} ->
        conn
        |> redirect(to: page_path(conn, :index, %{token: token}))
    end
  end

  defp create_or_set_user(name, fb_id) do
    
    case Accounts.get_user_by_fb(fb_id) do
      nil ->
        Accounts.create_user(%{"name" => name, "fb_id" => fb_id})
      user ->
        {:ok, user}
    end
  end
end
