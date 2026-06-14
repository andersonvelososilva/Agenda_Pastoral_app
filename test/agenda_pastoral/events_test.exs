defmodule AgendaPastoral.EventsTest do
  use AgendaPastoral.DataCase

  alias AgendaPastoral.Events
  alias AgendaPastoral.Events.Event

  import AgendaPastoral.EventsFixtures

  @invalid_attrs %{
    change_reason: nil,
    description: nil,
    end_at: nil,
    priority: nil,
    start_at: nil,
    status: nil,
    title: nil,
    type: nil,
    church_id: nil
  }

  describe "events" do
    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Enum.map(Events.list_events(), & &1.id) == [event.id]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id).id == event.id
    end

    test "create_event/1 with valid data creates an event" do
      church = AgendaPastoral.ChurchesFixtures.church_fixture()

      valid_attrs = %{
        change_reason: "some change_reason",
        description: "some description",
        end_at: ~U[2026-06-11 21:33:00Z],
        priority: "normal",
        start_at: ~U[2026-06-11 21:33:00Z],
        status: "scheduled",
        title: "some title",
        type: "some type",
        church_id: church.id
      }

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.change_reason == "some change_reason"
      assert event.description == "some description"
      assert event.end_at == ~U[2026-06-11 21:33:00Z]
      assert event.priority == "normal"
      assert event.start_at == ~U[2026-06-11 21:33:00Z]
      assert event.status == "scheduled"
      assert event.title == "some title"
      assert event.type == "some type"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
        change_reason: "some updated change_reason",
        description: "some updated description",
        end_at: ~U[2026-06-12 21:33:00Z],
        priority: "important",
        start_at: ~U[2026-06-12 21:33:00Z],
        status: "changed",
        title: "some updated title",
        type: "some updated type"
      }

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.change_reason == "some updated change_reason"
      assert event.description == "some updated description"
      assert event.end_at == ~U[2026-06-12 21:33:00Z]
      assert event.priority == "important"
      assert event.start_at == ~U[2026-06-12 21:33:00Z]
      assert event.status == "changed"
      assert event.title == "some updated title"
      assert event.type == "some updated type"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert Events.get_event!(event.id).id == event.id
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns an event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
