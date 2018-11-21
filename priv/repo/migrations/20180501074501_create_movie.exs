defmodule ElixirAnki.Repo.Migrations.CreateMovie do
  use Ecto.Migration

  def change do
    create table(:movie, primary_key: false) do
      add(:mid, :bigserial, primary_key: true, null: false)
      add(:title, :string, null: false)
      add(:year, :integer, null: false)
      add(:director, :string)

      timestamps()
    end
  end
end
