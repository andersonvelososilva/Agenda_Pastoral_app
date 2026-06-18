defmodule AgendaPastoralWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use AgendaPastoralWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-primary via-secondary to-accent z-[60]" />
    <header class="border-b border-base-200/50 bg-base-100/80 sticky top-0 z-50 backdrop-blur-lg">
      <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex h-16 justify-between items-center">
          <div class="flex items-center gap-3">
            <a href="/" class="flex items-center gap-2 group">
              <div class="size-8 rounded-lg bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-primary-content font-bold shadow-md shadow-primary/20 group-hover:scale-105 transition-transform">
                A
              </div>
              <div class="flex flex-col">
                <span class="text-base font-black tracking-tight text-base-content group-hover:text-primary transition-colors">
                  Agenda Pastoral
                </span>
                <span class="text-[10px] uppercase font-bold tracking-wider opacity-60">
                  São João dos Patos
                </span>
              </div>
            </a>
          </div>

          <nav class="hidden md:flex space-x-1 items-center bg-base-200/50 p-1 rounded-xl border border-base-300">
            <a href="/" class="px-3 py-1.5 text-xs font-bold rounded-lg hover:bg-base-100 hover:shadow-sm text-base-content/85 hover:text-primary transition-all duration-200">
              Início
            </a>
            <a href="/calendar" class="px-3 py-1.5 text-xs font-bold rounded-lg hover:bg-base-100 hover:shadow-sm text-base-content/85 hover:text-primary transition-all duration-200">
              Calendário
            </a>
            <a href="/churches" class="px-3 py-1.5 text-xs font-bold rounded-lg hover:bg-base-100 hover:shadow-sm text-base-content/85 hover:text-primary transition-all duration-200">
              Igrejas
            </a>
            <%= if @current_scope && @current_scope.user do %>
              <a href="/admin" class="px-3 py-1.5 text-xs font-bold rounded-lg bg-primary/10 text-primary hover:bg-primary/20 transition-all duration-200">
                Painel
              </a>
              <a href="/users/settings" class="px-3 py-1.5 text-xs font-bold rounded-lg hover:bg-base-100 hover:shadow-sm text-base-content/85 hover:text-primary transition-all duration-200">
                Ajustes
              </a>
              <span class="px-2 text-[10px] uppercase font-bold tracking-wider opacity-50" title={@current_scope.user.email}>
                {@current_scope.user.name}
              </span>
              <.link href={~p"/users/log-out"} method="delete" class="px-3 py-1.5 text-xs font-bold rounded-lg text-error hover:bg-error/10 transition-all duration-200">
                Sair
              </.link>
            <% else %>
              <a href="/users/log-in" class="px-3 py-1.5 text-xs font-bold rounded-lg hover:bg-base-100 hover:shadow-sm text-base-content/85 hover:text-primary transition-all duration-200">
                Entrar
              </a>
            <% end %>
          </nav>

          <div class="flex items-center gap-3">
            <.theme_toggle />

            <%!-- Mobile menu trigger --%>
            <div class="dropdown dropdown-end md:hidden">
              <button tabindex="0" class="btn btn-ghost btn-circle border border-base-300">
                <.icon name="hero-bars-3" class="size-5" />
              </button>
              <ul tabindex="0" class="dropdown-content menu p-2 shadow-2xl bg-base-100 rounded-2xl w-52 mt-4 border border-base-200/80">
                <li><a href="/" class="font-semibold">Início</a></li>
                <li><a href="/calendar" class="font-semibold">Calendário</a></li>
                <li><a href="/churches" class="font-semibold">Igrejas</a></li>
                <%= if @current_scope && @current_scope.user do %>
                  <li><a href="/admin" class="text-primary font-semibold">Painel</a></li>
                  <li class="menu-title px-4 py-2 text-[10px] uppercase font-bold tracking-wider opacity-60">{@current_scope.user.name}</li>
                  <li>
                    <.link href={~p"/users/log-out"} method="delete" class="text-error font-semibold">
                      Sair
                    </.link>
                  </li>
                <% else %>
                  <li><a href="/users/log-in" class="font-semibold">Entrar</a></li>
                <% end %>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </header>

    <main class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 [[data-theme-source=system]_&]:!left-0 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
