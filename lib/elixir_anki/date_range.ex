defmodule ElixirAnki.DateRange do
  use Ecto.Schema
  import Ecto.Changeset

  schema "date_ranges" do
    field(:end, :date)
    field(:start, :date)

    timestamps()
  end

  @doc false
  def changeset(date_range, attrs) do
    date_range
    |> cast(attrs, [:start, :end])
    |> validate_required([:start, :end])
  end
end

defmodule ElixirAnki.DateRangeApi do
  @moduledoc """
  The DateRanges context.
  """

  import Ecto.Query, warn: false
  alias ElixirAnki.Repo

  alias ElixirAnki.DateRange

  @doc """
  Returns the list of date_ranges.

  ## Examples

      iex> list()
      [%DateRange{}, ...]

  """
  def list do
    Repo.all(DateRange)
  end

  @doc """
  Gets a single date_range.

  Raises `Ecto.NoResultsError` if the Date range does not exist.

  ## Examples

      iex> get!(123)
      %DateRange{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(DateRange, id)

  @doc """
  Creates a date_range.

  ## Examples

      iex> create_(%{field: value})
      {:ok, %DateRange{}}

      iex> create_(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_(attrs \\ %{}) do
    %DateRange{}
    |> DateRange.changeset(attrs)
    |> Repo.insert()
  end
end
