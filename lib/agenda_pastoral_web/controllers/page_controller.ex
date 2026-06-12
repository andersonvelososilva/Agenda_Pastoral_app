defmodule AgendaPastoralWeb.PageController do
  use AgendaPastoralWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
