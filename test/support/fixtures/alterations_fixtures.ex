defmodule AgendaPastoral.AlterationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AgendaPastoral.Alterations` context.
  """

  import AgendaPastoral.AccountsFixtures
  import AgendaPastoral.EventsFixtures

  @doc """
  Generate an alteration.
  """
  def alteration_fixture(attrs \\ %{}) do
    event_id = Map.get(attrs, :event_id) || Map.get(attrs, "event_id") || event_fixture().id
    user_id = Map.get(attrs, :user_id) || Map.get(attrs, "user_id") || user_fixture().id

    attrs =
      Enum.into(attrs, %{
        description: "some description",
        event_id: event_id,
        user_id: user_id
      })

    {:ok, alteration} = AgendaPastoral.Alterations.create_alteration(attrs)
    alteration
  end
end
