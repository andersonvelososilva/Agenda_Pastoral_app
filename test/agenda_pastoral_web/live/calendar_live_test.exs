defmodule AgendaPastoralWeb.CalendarLiveTest do
  use AgendaPastoralWeb.ConnCase

  import Phoenix.LiveViewTest
  import AgendaPastoral.EventsFixtures

  test "renders calendar page", %{conn: conn} do
    event = event_fixture(%{title: "Batismo Especial"})

    {:ok, _view, html} = live(conn, ~p"/calendar")
    assert html =~ "Agenda Pastoral"
    assert html =~ "Calendário mensal"
    assert html =~ event.title
  end
end
