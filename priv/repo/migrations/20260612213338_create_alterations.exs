defmodule AgendaPastoral.Repo.Migrations.CreateAlterations do
  use Ecto.Migration

  def change do
    create table(:alterations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:alterations, [:user_id])

    create index(:alterations, [:event_id])
  end
end
