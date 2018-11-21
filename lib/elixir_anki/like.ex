defmodule ElixirAnki.Like do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirAnki.HighSchooler

  schema "likes" do
    field(:id2, :id)
    belongs_to(:highschooler, HighSchooler, foreign_key: :id1)

    timestamps()
  end

  def changeset(like, params) do
    like
    |> cast(params, [:id1, :id2])
    |> validate_required([:id1, :id2])
  end
end

defmodule ElixirAnki.LikeApi do
  alias ElixirAnki.Repo
  alias ElixirAnki.Like

  def list do
    Repo.all(Like)
  end

  def create_(params) do
    %Like{}
    |> Like.changeset(params)
    |> Repo.insert()
  end
end
