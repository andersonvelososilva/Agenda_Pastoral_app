defmodule AgendaPastoral.Districts do
  @moduledoc """
  The Districts context.
  """

  import Ecto.Query, warn: false
  alias AgendaPastoral.Repo
  alias AgendaPastoral.Districts.District

  @doc """
  Returns the list of districts.
  """
  def list_districts do
    Repo.all(District)
  end

  @doc """
  Gets a single district.
  """
  def get_district!(id), do: Repo.get!(District, id)

  @doc """
  Creates a district.
  """
  def create_district(attrs \\ %{}) do
    %District{}
    |> District.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a district.
  """
  def update_district(%District{} = district, attrs) do
    district
    |> District.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a district.
  """
  def delete_district(%District{} = district) do
    Repo.delete(district)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking district changes.
  """
  def change_district(%District{} = district, attrs \\ %{}) do
    District.changeset(district, attrs)
  end
end
