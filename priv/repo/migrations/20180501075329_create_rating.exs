defmodule ElixirAnki.Repo.Migrations.CreateRating do
  use Ecto.Migration

  def change do
    create table(:rating) do
      add(:rid, references(:reviewer, column: :rid), null: false)
      add(:mid, references(:movie, column: :mid), null: false)
      add(:stars, :integer, null: false)
      add(:ratingdate, :date)

      timestamps()
    end

    :rating
    |> index([:rid])
    |> create()

    :rating
    |> index([:mid])
    |> create()
  end
end
