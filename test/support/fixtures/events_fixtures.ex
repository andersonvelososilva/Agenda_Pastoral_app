defmodule AgendaPastoral.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AgendaPastoral.Events` context.
  """

  import AgendaPastoral.ChurchesFixtures

  @doc """
  Generate an event.
  """
  def event_fixture(attrs \\ %{}) do
    church_id = Map.get(attrs, :church_id) || Map.get(attrs, "church_id") || church_fixture().id

    attrs =
      Enum.into(attrs, %{
        change_reason: "some change_reason",
        description: "some description",
        end_at: ~U[2026-06-11 21:33:00Z],
        priority: "normal",
        start_at: ~U[2026-06-11 21:33:00Z],
        status: "scheduled",
        title: "some title",
        type: "some type",
        church_id: church_id
      })

    {:ok, event} = AgendaPastoral.Events.create_event(attrs)
    event
  end
end
