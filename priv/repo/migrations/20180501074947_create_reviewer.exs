defmodule ElixirAnki.Repo.Migrations.CreateReviewer do
  use Ecto.Migration

  def change do
    create table(:reviewer, primary_key: false) do
      add(:rid, :bigserial, primary_key: true, null: false)
      add(:name, :string, null: false)

      timestamps()
    end
  end
end
