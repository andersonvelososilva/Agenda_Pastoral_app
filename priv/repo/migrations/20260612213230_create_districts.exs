defmodule AgendaPastoral.Repo.Migrations.CreateDistricts do
  use Ecto.Migration

  def change do
    create table(:districts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :pastor_name, :string
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
