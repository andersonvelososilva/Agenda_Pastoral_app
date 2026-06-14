defmodule AgendaPastoralWeb.Admin.DashboardLive do
  use AgendaPastoralWeb, :live_view

  alias AgendaPastoral.Churches
  alias AgendaPastoral.Events
  alias AgendaPastoral.Announcements
  alias AgendaPastoral.Alterations

  @impl true
  def mount(_params, _session, socket) do
    churches = Churches.list_churches()
    events = Events.list_events()
    announcements = Announcements.list_announcements()
    alterations = Alterations.list_alterations()

    socket =
      assign(socket,
        total_churches: length(churches),
        total_events: length(events),
        total_announcements: length(announcements),
        total_alterations: length(alterations),
        recent_events: Enum.take(events, 5),
        recent_announcements: Enum.take(announcements, 3)
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <%!-- Header --%>
        <div class="py-4 border-b border-base-200">
          <h1 class="text-3xl font-extrabold text-base-content">
            Painel do Pastor
          </h1>
          <p class="text-sm opacity-60">
            Gerenciamento administrativo do Distrito de São João dos Patos
          </p>
        </div>

        <%!-- Metricas / Cards --%>
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <div class="p-5 bg-base-100 border border-base-200 shadow-sm rounded-2xl">
            <span class="text-xs font-semibold opacity-50 uppercase">Igrejas</span>
            <p class="text-3xl font-black mt-1 text-primary">{@total_churches}</p>
          </div>
          <div class="p-5 bg-base-100 border border-base-200 shadow-sm rounded-2xl">
            <span class="text-xs font-semibold opacity-50 uppercase">Eventos</span>
            <p class="text-3xl font-black mt-1 text-secondary">{@total_events}</p>
          </div>
          <div class="p-5 bg-base-100 border border-base-200 shadow-sm rounded-2xl">
            <span class="text-xs font-semibold opacity-50 uppercase">Avisos</span>
            <p class="text-3xl font-black mt-1 text-accent">{@total_announcements}</p>
          </div>
          <div class="p-5 bg-base-100 border border-base-200 shadow-sm rounded-2xl">
            <span class="text-xs font-semibold opacity-50 uppercase">Alterações</span>
            <p class="text-3xl font-black mt-1 text-warning">{@total_alterations}</p>
          </div>
        </div>

        <%!-- Atalhos / Navegação --%>
        <div class="bg-base-200/40 p-6 rounded-2xl border border-base-200 flex flex-col md:flex-row gap-4 items-center justify-between">
          <div>
            <h3 class="font-bold text-lg text-base-content">Ações Rápidas</h3>
            <p class="text-xs opacity-60">Escolha uma seção para gerenciar</p>
          </div>
          <div class="flex flex-wrap gap-2 w-full md:w-auto">
            <.link
              navigate={~p"/admin/events"}
              class="btn btn-primary btn-sm rounded-xl flex items-center gap-1.5 flex-1 md:flex-none"
            >
              <.icon name="hero-calendar-days" class="size-4" /> Gerenciar Eventos
            </.link>
            <.link
              navigate={~p"/admin/announcements"}
              class="btn btn-secondary btn-sm rounded-xl flex items-center gap-1.5 flex-1 md:flex-none"
            >
              <.icon name="hero-megaphone" class="size-4" /> Gerenciar Avisos
            </.link>
            <.link
              navigate={~p"/admin/history"}
              class="btn btn-ghost border border-base-300 btn-sm rounded-xl flex items-center gap-1.5 flex-1 md:flex-none"
            >
              <.icon name="hero-queue-list" class="size-4" /> Histórico de Alterações
            </.link>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
