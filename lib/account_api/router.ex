defmodule Accounts.Router do
  use Plug.Router
  use Timex
  alias Accounts.Account
  import Ecto.Query

  alias Accounts.Auth
  require Logger

  plug(Plug.Logger, log: :debug)
  @skip_token_verification %{jwt_skip: true}

  plug(:match)
  plug Accounts.AuthPlug
  plug CORSPlug, origin: "*"
  plug(:dispatch)

  post "/login", private: @skip_token_verification do
    {username, password} = {
      Map.get(conn.params, "username", nil),
      Map.get(conn.params, "password", nil)
    }
    account = Accounts.Repo.one(from d in Accounts.Account, where: d."Username" == ^username and d."Password" == ^password)
    Logger.debug inspect(account)

    flag = case account != nil  do
       true ->
        {:ok, auth_service} = Accounts.Auth.start_link
        Logger.debug inspect(auth_service)
        id = account."AccountId"
        Logger.debug inspect(account |> Map.drop([:Password]))

        case Accounts.Auth.issue_token(auth_service, %{:id => id}) do
          token ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Poison.encode!(%{id: id, token: token}))
         :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Poison.encode!(%{:message => "token already issued"}))
        end
      false ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Poison.encode!(%{:message => "departamentul microsoft -> neatorizat!"}))

    end
  end
  post "/logout" do
    id = Map.get(conn.params, "id", nil)

    case Accounts.Auth.revoke_token(conn.assigns.auth_service, %{:id => id}) do
      :ok ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Poison.encode!(%{:message => "token was deleted"}))
      :error ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Poison.encode!(%{:message => "token was not deleted"}))
    end
  end

  post "/validate-token", private: @skip_token_verification do
    token = Map.get(conn.params, "token", nil)
    Logger.debug inspect(token)

    {:ok, service} = Accounts.Auth.start_link
    case Accounts.Auth.validate_token(service, token) do
          {:ok, _} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Poison.encode!(%{:message => "token is valid"}))
          {:error, _} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Poison.encode!(%{:message => "token is invalid"}))
        end

  end


  get "/get-all" do
    accounts =  Accounts.Repo.all(from d in Accounts.Account)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(accounts))
  end
  post "/register", private: @skip_token_verification do
    {username, password} = {
           Map.get(conn.params, "username", nil),
           Map.get(conn.params, "password", nil)
         }

    cond do
           is_nil(username) ->
             conn
             |> put_status(400)
             |> assign(:jsonapi, %{"error" => "'username' field must be provided"})
           is_nil(password) ->
             conn
             |> put_status(400)
             |> assign(:jsonapi, %{"error" => "'password' field must be provided"})
           true ->
             case %Account{
              Username: username,
              Password: password
            } |> Accounts.Repo.insert do
              {:ok, new_account} ->
                conn
                |> put_resp_content_type("application/json")
                |> send_resp(201, Poison.encode!(%{:data => new_account}))
              :error ->
                conn
                |> put_resp_content_type("application/json")
                |> send_resp(507, Poison.encode!(%{"error" => "An unexpected error happened"}))
             end
         end
  end

end