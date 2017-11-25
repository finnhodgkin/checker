defmodule CheckerWeb.AuthController do
  use CheckerWeb, :controller

  plug Ueberauth
  def callback(%{assigns: %{ueberauth_auth: %{extra: %{raw_info: %{user: %{"id" => id}}}}}} = conn, _params) do
    IO.inspect id

    conn
    |> put_session(:user_id, id)
    |> redirect(to: page_path(conn, :index, %{token: 123}))

  end
  #
  # def signout(conn, _params) do
  #
  #   # conn
  #   # |> put_flash(:info, "Signed out")
  #   # |> configure_session(drop: true)
  #   # |> redirect(to: todo_path(conn, :index))
  # end
  #
  # defp insert_or_sign_user(user) do
  #   # case Users.get_by_email(user.email) do
  #   #   nil ->
  #   #     Users.create_user(user)
  #   #   user ->
  #   #     {:ok, user}
  #   # end
  # end
end
