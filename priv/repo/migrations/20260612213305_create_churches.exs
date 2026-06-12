defmodule AgendaPastoral.Repo.Migrations.CreateChurches do
  use Ecto.Migration

  def change do
    create table(:churches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :city, :string
      add :state, :string
      add :active, :boolean, default: true, null: false
      add :district_id, references(:districts, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:churches, [:district_id])
  end
end
