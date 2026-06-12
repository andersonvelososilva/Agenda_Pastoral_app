defmodule AgendaPastoral.Districts.District do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "districts" do
    field :name, :string
    field :pastor_name, :string
    field :active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(district, attrs) do
    district
    |> cast(attrs, [:name, :pastor_name, :active])
    |> validate_required([:name, :pastor_name, :active])
  end
end
