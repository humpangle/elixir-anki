defmodule ElixirAnki.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add(
        :id1,
        references(:highschooler, on_delete: :delete_all),
        null: false
      )

      add(
        :id2,
        references(:highschooler, on_delete: :delete_all),
        null: false
      )

      timestamps()
    end

    create(index(:likes, [:id1]))
    create(index(:likes, [:id2]))
  end
end
