defmodule ElixirAnki.Repo.Migrations.CreateHighschooler do
  use Ecto.Migration

  def change do
    create table(:highschooler) do
      add(:name, :string, null: false)
      add(:grade, :integer, null: false)
      timestamps()
    end
  end
end
