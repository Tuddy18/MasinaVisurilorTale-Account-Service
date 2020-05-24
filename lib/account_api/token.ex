defmodule Accounts.Token do
#  use Accounts.Models.Base
#  alias Accounts.DB.Manager

  # Poison Enconder Type
  @derive [Poison.Encoder]

  defstruct [
    :id,
    :type, #activation, reset
    :user,
    :used,
    :expires_at,
    :created_at,
    :updated_at
  ]
end
