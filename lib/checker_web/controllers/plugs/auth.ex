defmodule CheckerWeb.Plugs.Auth do
  import Plug.Conn

  alias Checker.Accounts

  def init(_params) do
  end

  def call(conn, _init_params) do
    id = case get_req_header(conn, "authorization") do
      [] ->
        nil
      [token] ->
        case Checker.Guardian.decode_and_verify(token) do
          {:ok, %{"sub" => sub}} ->
            sub
          _ -> nil
        end
    end

    cond do
      user = id && Accounts.get_user_by_fb(id) ->
        assign(conn, :user, user)
      true ->
        assign(conn, :user, nil)
    end
    # IO.inspect token

    # {:ok, claims} = MyApp.Guardian.decode_and_verify(token)

    # IO.inspect claims

    # cond do
    #   user = user_id && Accounts.get_user_fb(user_id) ->
    #     assign(conn, :user, user)
    #   true ->
    #     assign(conn, :user, nil)
    # end
  end
end
