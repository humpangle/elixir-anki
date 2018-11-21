defmodule ElixirAnki.HighSchooler do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirAnki.Friend
  alias ElixirAnki.Like

  schema "highschooler" do
    field(:name, :string)
    field(:grade, :integer)
    has_many(:friends, Friend, foreign_key: :id1)
    has_many(:i_like, Like, foreign_key: :id1)
    has_many(:like_me, Like, foreign_key: :id2)

    timestamps()
  end

  def changeset(hschooler, params \\ %{}) do
    hschooler
    |> cast(params, [:id, :name, :grade])
    |> validate_required([:name, :grade])
  end
end

defmodule ElixirAnki.HighSchoolerApi do
  import Ecto.Query, warn: false

  alias ElixirAnki.Repo
  alias ElixirAnki.HighSchooler

  def create_(params) do
    %HighSchooler{}
    |> HighSchooler.changeset(params)
    |> Repo.insert()
  end

  def list do
    Repo.all(HighSchooler)
  end

  def get!(id) do
    Repo.get!(HighSchooler, id)
  end
end
