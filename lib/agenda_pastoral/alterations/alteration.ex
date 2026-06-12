defmodule AgendaPastoral.Alterations.Alteration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "alterations" do
    field :description, :string

    belongs_to :event, AgendaPastoral.Events.Event
    belongs_to :user, AgendaPastoral.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(alteration, attrs) do
    alteration
    |> cast(attrs, [:description, :event_id, :user_id])
    |> validate_required([:description, :event_id, :user_id])
  end
end
