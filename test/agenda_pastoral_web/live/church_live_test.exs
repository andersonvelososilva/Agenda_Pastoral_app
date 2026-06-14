defmodule AgendaPastoralWeb.ChurchLiveTest do
  use AgendaPastoralWeb.ConnCase

  import Phoenix.LiveViewTest
  import AgendaPastoral.ChurchesFixtures

  test "renders churches list page", %{conn: conn} do
    church = church_fixture(%{name: "Igreja Central"})

    {:ok, _view, html} = live(conn, ~p"/churches")
    assert html =~ "Igrejas do Distrito"
    assert html =~ "Igreja Central"
  end

  test "renders church show page with details", %{conn: conn} do
    church = church_fixture(%{name: "Igreja de Olaria", city: "Patos"})

    {:ok, _view, html} = live(conn, ~p"/churches/#{church.id}")
    assert html =~ "Igreja de Olaria"
    assert html =~ "Voltar para todas as igrejas"
  end
end
