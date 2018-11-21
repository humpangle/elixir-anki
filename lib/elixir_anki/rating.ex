defmodule ElixirAnki.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirAnki.Movie
  alias ElixirAnki.Reviewer

  schema "rating" do
    field(:ratingdate, :date)
    field(:stars, :integer)
    field(:rid, :integer)

    belongs_to(
      :movie,
      Movie,
      foreign_key: :mid,
      references: :mid
    )

    belongs_to(
      :reviewer,
      Reviewer,
      references: :rid,
      foreign_key: :rid,
      define_field: false
    )

    timestamps()
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:rid, :mid, :stars, :ratingdate])
    |> validate_required([:rid, :mid, :stars])
  end
end

defmodule ElixirAnki.RatingApi do
  import Ecto.Query, warn: false
  alias ElixirAnki.Repo

  alias ElixirAnki.Rating

  @doc """
  Returns the list of rating.

  ## Examples

      iex> list()
      [%Rating{}, ...]

  """
  def list do
    Repo.all(Rating)
  end

  @doc """
  Gets a single rating.

  Raises `Ecto.NoResultsError` if the Rating does not exist.

  ## Examples

      iex> get!(123)
      %Rating{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Rating, id)

  @doc """
  Creates a rating.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Rating{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_(attrs \\ %{}) do
    %Rating{}
    |> Rating.changeset(attrs)
    |> Repo.insert()
  end
end
