defmodule AgendaPastoral.DistrictsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AgendaPastoral.Districts` context.
  """

  @doc """
  Generate a district.
  """
  def district_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        active: true,
        name: "some name",
        pastor_name: "some pastor_name"
      })

    {:ok, district} = AgendaPastoral.Districts.create_district(attrs)
    district
  end
end
