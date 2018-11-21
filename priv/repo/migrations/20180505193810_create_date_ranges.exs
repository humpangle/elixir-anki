defmodule ElixirAnki.Repo.Migrations.CreateDateRanges do
  use Ecto.Migration

  def change do
    create table(:date_ranges) do
      add(:start, :date, null: false)
      add(:end, :date, null: false)

      timestamps()
    end
  end
end
