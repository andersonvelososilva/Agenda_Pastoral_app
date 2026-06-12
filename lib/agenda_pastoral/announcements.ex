defmodule AgendaPastoral.Announcements do
  @moduledoc """
  The Announcements context.
  """

  import Ecto.Query, warn: false
  alias AgendaPastoral.Repo
  alias AgendaPastoral.Announcements.Announcement

  @doc """
  Returns the list of announcements.
  """
  def list_announcements do
    Repo.all(Announcement) |> Repo.preload(:publisher)
  end

  @doc """
  Returns the list of recent announcements.
  """
  def list_recent_announcements(limit \\ 5) do
    Repo.all(
      from a in Announcement,
        order_by: [desc: a.inserted_at],
        limit: ^limit,
        preload: :publisher
    )
  end

  @doc """
  Gets a single announcement.
  """
  def get_announcement!(id), do: Repo.get!(Announcement, id) |> Repo.preload(:publisher)

  @doc """
  Creates a announcement.
  """
  def create_announcement(attrs \\ %{}) do
    %Announcement{}
    |> Announcement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a announcement.
  """
  def update_announcement(%Announcement{} = announcement, attrs) do
    announcement
    |> Announcement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a announcement.
  """
  def delete_announcement(%Announcement{} = announcement) do
    Repo.delete(announcement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking announcement changes.
  """
  def change_announcement(%Announcement{} = announcement, attrs \\ %{}) do
    Announcement.changeset(announcement, attrs)
  end
end
