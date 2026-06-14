defmodule AgendaPastoral.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field :title, :string
    field :description, :string
    field :start_at, :utc_datetime
    field :end_at, :utc_datetime
    field :type, :string
    field :priority, :string, default: "normal"
    field :status, :string, default: "scheduled"
    field :change_reason, :string

    belongs_to :church, AgendaPastoral.Churches.Church
    belongs_to :creator, AgendaPastoral.Accounts.User, foreign_key: :created_by

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :title,
      :description,
      :start_at,
      :end_at,
      :type,
      :priority,
      :status,
      :change_reason,
      :church_id,
      :created_by
    ])
    |> validate_required([:title, :start_at, :end_at, :type, :priority, :status, :church_id])
  end
end
