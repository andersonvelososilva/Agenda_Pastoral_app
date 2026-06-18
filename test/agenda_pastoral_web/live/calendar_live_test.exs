defmodule AgendaPastoralWeb.CalendarLiveTest do
  use AgendaPastoralWeb.ConnCase

  import Phoenix.LiveViewTest
  import AgendaPastoral.EventsFixtures

  test "renders calendar page", %{conn: conn} do
    event = event_fixture(%{title: "Batismo Especial"})

    {:ok, _view, html} = live(conn, ~p"/calendar")
    assert html =~ "Agenda Distrital"
    assert html =~ "Calendário de visitas"
    assert html =~ event.title
  end
end
