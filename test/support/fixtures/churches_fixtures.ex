defmodule AgendaPastoral.ChurchesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AgendaPastoral.Churches` context.
  """

  import AgendaPastoral.DistrictsFixtures

  @doc """
  Generate a church.
  """
  def church_fixture(attrs \\ %{}) do
    district = Map.get(attrs, :district_id) || Map.get(attrs, "district_id") || district_fixture().id

    attrs =
      Enum.into(attrs, %{
        active: true,
        city: "some city",
        name: "some name",
        state: "some state",
        district_id: district
      })

    {:ok, church} = AgendaPastoral.Churches.create_church(attrs)
    church
  end
end
