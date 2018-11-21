defmodule ElixirAnki.User do
  use Ecto.Schema
  import Ecto.Changeset

  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  schema "users" do
    field(:email, :string)
    field(:password_hash, :string)
    field(:username, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash])
    |> validate_required([:username, :email, :password_hash])
    |> validate_format(:email, @mail_regex)
    |> unique_constraint(:email)
  end
end
