defmodule AgendaPastoral.Announcements.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "announcements" do
    field :title, :string
    field :content, :string

    belongs_to :publisher, AgendaPastoral.Accounts.User, foreign_key: :published_by

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:title, :content, :published_by])
    |> validate_required([:title, :content])
  end
end
