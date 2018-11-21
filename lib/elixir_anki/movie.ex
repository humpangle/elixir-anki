defmodule ElixirAnki.Movie do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirAnki.Rating

  @primary_key {:mid, :id, autogenerate: true}

  schema "movie" do
    field(:director, :string)
    field(:title, :string)
    field(:year, :integer)
    has_many(:ratings, Rating, foreign_key: :mid)

    timestamps()
  end

  @doc false
  def changeset(movie, attrs) do
    movie
    |> cast(attrs, [:mid, :title, :year, :director])
    |> validate_required([:title, :year])
  end
end

defmodule ElixirAnki.MovieApi do
  import Ecto.Query, warn: false
  alias ElixirAnki.Repo

  alias ElixirAnki.Movie

  @doc """
  Returns the list of movie.

  ## Examples

      iex> list()
      [%Movie{}, ...]

  """
  def list do
    Repo.all(Movie)
  end

  @doc """
  Gets a single movie.

  Raises `Ecto.NoResultsError` if the Movie does not exist.

  ## Examples

      iex> get!(123)
      %Movie{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Movie, id)

  @doc """
  Creates a movie.

  ## Examples

      iex> create_(%{field: value})
      {:ok, %Movie{}}

      iex> create_(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_(attrs \\ %{}) do
    %Movie{}
    |> Movie.changeset(attrs)
    |> Repo.insert()
  end
end
