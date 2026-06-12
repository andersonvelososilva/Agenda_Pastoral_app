defmodule AgendaPastoral.Churches.Church do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "churches" do
    field :name, :string
    field :city, :string
    field :state, :string
    field :active, :boolean, default: true
    belongs_to :district, AgendaPastoral.Districts.District

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [:name, :city, :state, :active, :district_id])
    |> validate_required([:name, :city, :state, :active, :district_id])
  end
end
