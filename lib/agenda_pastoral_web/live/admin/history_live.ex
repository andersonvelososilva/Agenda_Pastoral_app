defmodule AgendaPastoralWeb.Admin.HistoryLive do
  use AgendaPastoralWeb, :live_view

  alias AgendaPastoral.Alterations

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, alterations: Alterations.list_alterations())}
  end

  defp format_datetime(datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    pad = fn val -> String.pad_leading("#{val}", 2, "0") end

    "#{local_dt.day}/#{String.pad_leading("#{local_dt.month}", 2, "0")}/#{local_dt.year} às #{pad.(local_dt.hour)}:#{pad.(local_dt.minute)}"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <%!-- Breadcrumbs --%>
        <div>
          <.link
            navigate={~p"/admin"}
            class="inline-flex items-center gap-1 text-sm font-semibold text-primary hover:underline"
          >
            <.icon name="hero-arrow-left" class="size-4" /> Voltar para o painel
          </.link>
        </div>

        <%!-- Header --%>
        <div class="py-4 border-b border-base-200">
          <h1 class="text-3xl font-extrabold text-base-content">
            Histórico de Alterações
          </h1>
          <p class="text-sm opacity-60">Lista de modificações realizadas na agenda pastoral</p>
        </div>

        <%!-- Lista de Alterações --%>
        <%= if Enum.empty?(@alterations) do %>
          <div class="p-8 bg-base-100 rounded-2xl border border-base-200 text-center">
            <p class="text-base-content opacity-60">Nenhuma alteração registrada até o momento.</p>
          </div>
        <% else %>
          <div class="bg-base-100 border border-base-200 rounded-2xl overflow-hidden shadow-sm">
            <div class="divide-y divide-base-200">
              <div
                :for={alt <- @alterations}
                class="p-5 flex flex-col sm:flex-row justify-between sm:items-center gap-4"
              >
                <div class="flex items-start gap-3">
                  <div class="p-2 bg-amber-500/10 rounded-lg text-amber-500 mt-0.5">
                    <.icon name="hero-exclamation-triangle" class="size-5" />
                  </div>
                  <div>
                    <p class="text-sm font-bold text-base-content">
                      {alt.description}
                    </p>
                    <p class="text-xs opacity-60 mt-1">
                      Evento relacionado: <span class="font-bold">{alt.event.title}</span> •
                      Igreja: <span class="font-bold">{alt.event.church.name}</span>
                    </p>
                  </div>
                </div>
                <div class="text-left sm:text-right shrink-0">
                  <span class="block text-xs font-semibold">Alterado por: {alt.user.name}</span>
                  <span class="block text-[11px] opacity-50 mt-1">{format_datetime(alt.inserted_at)}</span>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
