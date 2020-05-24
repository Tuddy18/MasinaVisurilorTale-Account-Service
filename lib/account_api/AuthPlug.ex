defmodule Accounts.AuthPlug do
   import Plug.Conn
  require Logger

  def init(opts), do: opts
  def call(conn, _opts) do
    #doar exemplu!
    #https://devhints.io/phoenix-conn
    cond do
      conn.private |> Map.get(:jwt_skip, false) ->
        # Skipping authentication
        conn
      true ->
        {:ok, service} = Accounts.Auth.start_link

        conn = conn |> assign(:auth_service, service)

        auth_header = conn
                |> get_req_header("authorization")
                |> List.first()
        Logger.debug inspect(auth_header)

        case auth_header do
          nil ->
            send_resp(conn, 402, "No authorization token found!") |> halt
          raw_token ->
            jwt_compact = raw_token
                      |> String.split(" ")
                      |> List.last()
                case Accounts.Auth.validate_token(service, jwt_compact) do
                  {:ok, _} -> conn
                  {:error, _} ->
                  Accounts.Auth.stop(service)
                  conn |> forbidden
              end
        end

    end
  end

  defp forbidden(conn) do
    send_resp(conn, 401, "Unauthorized!") |> halt
  end

end
