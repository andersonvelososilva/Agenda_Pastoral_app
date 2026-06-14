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

  @doc """
  Returns all active churches and pre-calculates the next visit of the pastor.
  """
  def list_churches_with_next_event do
    churches = Repo.all(from c in Church, where: c.active == true, order_by: [asc: c.name])
    
    now = DateTime.utc_now()
    upcoming_events = Repo.all(
      from e in AgendaPastoral.Events.Event,
        where: e.start_at >= ^now and e.status != "cancelled",
        order_by: [asc: e.start_at]
    )

    events_by_church = Enum.group_by(upcoming_events, & &1.church_id)

    Enum.map(churches, fn church ->
      church_events = Map.get(events_by_church, church.id, [])
      next_event = List.first(church_events)
      {church, next_event}
    end)
  end

  @doc """
  Gets a church and its upcoming events.
  """
  def get_church_with_upcoming_events!(id) do
    church = Repo.get!(Church, id)
    now = DateTime.utc_now()
    
    events = Repo.all(
      from e in AgendaPastoral.Events.Event,
        where: e.church_id == ^church.id and e.start_at >= ^now and e.status != "cancelled",
        order_by: [asc: e.start_at]
    )

    {church, events}
  end
end
