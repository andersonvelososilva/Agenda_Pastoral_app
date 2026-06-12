defmodule AgendaPastoral.Churches do
  @moduledoc """
  The Churches context.
  """

  import Ecto.Query, warn: false
  alias AgendaPastoral.Repo
  alias AgendaPastoral.Churches.Church

  @doc """
  Returns the list of churches.
  """
  def list_churches do
    Repo.all(Church)
  end

  @doc """
  Gets a single church.
  """
  def get_church!(id), do: Repo.get!(Church, id)

  @doc """
  Creates a church.
  """
  def create_church(attrs \\ %{}) do
    %Church{}
    |> Church.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a church.
  """
  def update_church(%Church{} = church, attrs) do
    church
    |> Church.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a church.
  """
  def delete_church(%Church{} = church) do
    Repo.delete(church)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking church changes.
  """
  def change_church(%Church{} = church, attrs \\ %{}) do
    Church.changeset(church, attrs)
  end
end
