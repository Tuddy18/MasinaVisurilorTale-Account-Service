defmodule Accounts.Endpoint do
  require Logger
  use Plug.Router

  alias Accounts.Auth
    alias Accounts.Account
      import Ecto.Query


  plug(:match)

  @skip_token_verification %{jwt_skip: true}
  plug CORSPlug, origin: "*"

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )
#  plug Accounts.AuthPlug
  plug(:dispatch)

  forward("/account", to: Accounts.Router)

  match _ do
    send_resp(conn, 404, "Page not found!")
  end

end
