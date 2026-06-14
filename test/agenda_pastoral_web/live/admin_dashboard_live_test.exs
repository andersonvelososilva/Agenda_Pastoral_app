defmodule AgendaPastoralWeb.Admin.DashboardLiveTest do
  use AgendaPastoralWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  test "renders admin dashboard page for logged-in users", %{conn: conn, user: _user} do
    {:ok, _view, html} = live(conn, ~p"/admin")
    assert html =~ "Painel do Pastor"
    assert html =~ "Gerenciar Eventos"
    assert html =~ "Gerenciar Avisos"
  end
end
