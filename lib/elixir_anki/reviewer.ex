defmodule ElixirAnki.Reviewer do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirAnki.Rating

  @primary_key {:rid, :id, autogenerate: true}

  schema "reviewer" do
    field(:name, :string)
    has_many(:ratings, Rating, foreign_key: :rid)

    timestamps()
  end

  @doc false
  def changeset(reviewer, attrs) do
    reviewer
    |> cast(attrs, [:rid, :name])
    |> validate_required([:name])
  end
end

defmodule ElixirAnki.ReviewerApi do
  import Ecto.Query, warn: false
  alias ElixirAnki.Repo

  alias ElixirAnki.Reviewer

  @doc """
  Returns the list of reviewer.

  ## Examples

      iex> list()
      [%Reviewer{}, ...]

  """
  def list do
    Repo.all(Reviewer)
  end

  @doc """
  Gets a single reviewer.

  Raises `Ecto.NoResultsError` if the Reviewer does not exist.

  ## Examples

      iex> get!(123)
      %Reviewer{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Reviewer, id)

  @doc """
  Creates a reviewer.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Reviewer{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_(attrs \\ %{}) do
    %Reviewer{}
    |> Reviewer.changeset(attrs)
    |> Repo.insert()
  end
end
