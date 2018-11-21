defmodule ElixirAnki.Repo.Migrations.CreateFriends do
  use Ecto.Migration

  def change do
    create table(:friend) do
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

    create(index(:friend, [:id1]))
    create(index(:friend, [:id2]))
  end
end
