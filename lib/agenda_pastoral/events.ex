defmodule AgendaPastoral.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias AgendaPastoral.Repo
  alias AgendaPastoral.Events.Event

  @doc """
  Returns the list of events.
  """
  def list_events do
    Repo.all(Event) |> Repo.preload([:church, :creator])
  end

  @doc """
  Gets a single event.
  """
  def get_event!(id) do
    Repo.get!(Event, id) |> Repo.preload([:church, :creator])
  end

  @doc """
  Creates an event.
  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an event.
  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an event.
  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.
  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  # Custom Queries for Dashboard and Lists

  @doc """
  Gets the current date in Brasília (UTC-3) time.
  """
  def today_br do
    DateTime.utc_now()
    |> DateTime.add(-3, :hour)
    |> DateTime.to_date()
  end

  @doc """
  List events happening today in Brasília (UTC-3) time.
  """
  def list_today_events do
    today = today_br()
    # Convert local day boundaries to UTC datetimes
    start_dt = DateTime.new!(today, ~T[00:00:00], "Etc/UTC") |> DateTime.add(3, :hour)
    end_dt = DateTime.new!(today, ~T[23:59:59], "Etc/UTC") |> DateTime.add(3, :hour)

    Repo.all(
      from e in Event,
        where: e.start_at >= ^start_dt and e.start_at <= ^end_dt,
        preload: [:church],
        order_by: [asc: e.start_at]
    )
  end

  @doc """
  List upcoming events starting from now.
  """
  def list_upcoming_events(limit \\ 10) do
    now = DateTime.utc_now()

    Repo.all(
      from e in Event,
        where: e.start_at >= ^now,
        preload: [:church],
        order_by: [asc: e.start_at],
        limit: ^limit
    )
  end

  @doc """
  List events for a specific month and year.
  """
  def list_events_for_month(year, month) do
    start_date = Date.new!(year, month, 1)
    days_in_month = Date.days_in_month(start_date)
    end_date = Date.new!(year, month, days_in_month)

    start_dt = DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") |> DateTime.add(3, :hour)
    end_dt = DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC") |> DateTime.add(3, :hour)

    Repo.all(
      from e in Event,
        where: e.start_at >= ^start_dt and e.start_at <= ^end_dt,
        preload: [:church],
        order_by: [asc: e.start_at]
    )
  end
end
