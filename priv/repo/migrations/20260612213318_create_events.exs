defmodule AgendaPastoral.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :description, :text
      add :start_at, :utc_datetime
      add :end_at, :utc_datetime
      add :type, :string
      add :priority, :string
      add :status, :string
      add :change_reason, :text
      add :church_id, references(:churches, on_delete: :nothing, type: :binary_id)
      add :created_by, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:events, [:church_id])
    create index(:events, [:created_by])
  end
end
