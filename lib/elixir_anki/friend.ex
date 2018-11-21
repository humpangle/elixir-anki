defmodule ElixirAnki.Friend do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirAnki.HighSchooler
  alias ElixirAnki.Friend

  schema "friend" do
    field(:id2, :id)
    belongs_to(:highschooler, HighSchooler, foreign_key: :id1)

    timestamps()
  end

  def changeset(friend, params) do
    friend
    |> cast(params, [:id1, :id2])
    |> validate_required([:id1, :id2])
  end
end

defmodule ElixirAnki.FriendApi do
  alias ElixirAnki.Friend
  alias ElixirAnki.Repo

  def create_(%{id1: id1, id2: id2} = params) do
    Repo.transaction(fn ->
      {:ok, friend1} =
        %Friend{}
        |> Friend.changeset(params)
        |> Repo.insert()

      {:ok, friend2} =
        %Friend{}
        |> Friend.changeset(%{id1: id2, id2: id1})
        |> Repo.insert()

      {:ok, friend1, friend2}
    end)
  end

  def list do
    Repo.all(Friend)
  end

  def get!(id) do
    Repo.get!(Friend, id)
  end
end
