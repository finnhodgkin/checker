defmodule Checker.Guardian do
  use Guardian, otp_app: :checker

  alias Checker.Accounts

  def subject_for_token(id, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Accounts.get_user(id)
    {:ok,  resource}
  end
end
