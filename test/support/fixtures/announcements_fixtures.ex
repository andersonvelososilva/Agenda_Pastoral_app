defmodule AgendaPastoral.AnnouncementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AgendaPastoral.Announcements` context.
  """

  @doc """
  Generate an announcement.
  """
  def announcement_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        content: "some content",
        title: "some title"
      })

    {:ok, announcement} = AgendaPastoral.Announcements.create_announcement(attrs)
    announcement
  end
end
