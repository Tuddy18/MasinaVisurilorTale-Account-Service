defmodule Accounts.Account do
  use Ecto.Schema

  @primary_key {:AccountId, :id, autogenerate: true}
#  @derive {Poison.Encoder, only: [:name, :age]}
  schema "Account" do
    field :Username, :string
    field :Password, :string
  end

end