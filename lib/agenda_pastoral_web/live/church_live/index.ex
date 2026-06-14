defmodule AgendaPastoralWeb.ChurchLive.Index do
  use AgendaPastoralWeb, :live_view

  alias AgendaPastoral.Churches

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AgendaPastoral.PubSub, "events")
    end

    socket =
      socket
      |> assign(search_query: "")
      |> assign_churches()

    {:ok, socket}
  end

  defp assign_churches(socket) do
    search = String.downcase(socket.assigns.search_query)

    # Fetch churches and their pre-calculated next events
    churches_with_events = Churches.list_churches_with_next_event()

    filtered =
      if search == "" do
        churches_with_events
      else
        Enum.filter(churches_with_events, fn {church, _next_event} ->
          String.contains?(String.downcase(church.name), search) ||
            String.contains?(String.downcase(church.city), search)
        end)
      end

    assign(socket, churches: filtered)
  end

  @impl true
  def handle_info({_action, _model}, socket) do
    # When events are updated/changed in real time, reload the list
    {:noreply, assign_churches(socket)}
  end

  @impl true
  def handle_event("search", %{"value" => query}, socket) do
    socket =
      socket
      |> assign(search_query: query)
      |> assign_churches()

    {:noreply, socket}
  end

  # Helpers
  defp format_datetime(nil), do: "Sem visitas programadas"
  defp format_datetime(datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    date_str = format_date(DateTime.to_date(local_dt))
    time_str = format_time(datetime)
    "#{date_str} às #{time_str}"
  end

  defp format_date(date) do
    months = %{
      1 => "jan", 2 => "fev", 3 => "mar", 4 => "abr", 5 => "mai", 6 => "jun",
      7 => "jul", 8 => "ago", 9 => "set", 10 => "out", 11 => "nov", 12 => "dez"
    }
    days = %{
      1 => "Seg", 2 => "Ter", 3 => "Qua", 4 => "Qui", 5 => "Sex", 6 => "Sáb", 7 => "Dom"
    }
    day_of_week = Date.day_of_week(date, :sunday)
    "#{Map.get(days, day_of_week)}, #{date.day} #{Map.get(months, date.month)}"
  end

  defp format_time(datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    pad = fn val -> String.pad_leading("#{val}", 2, "0") end
    "#{pad.(local_dt.hour)}:#{pad.(local_dt.minute)}"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        
        <%!-- Header --%>
        <div class="py-4 border-b border-base-200">
          <h1 class="text-3xl font-extrabold tracking-tight text-base-content">
            Igrejas do Distrito
          </h1>
          <p class="text-sm opacity-60">Consulte as congregações locais e suas escalas pastorais</p>
        </div>

        <%!-- Barra de busca --%>
        <div class="relative w-full">
          <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-base-content opacity-40">
            <.icon name="hero-magnifying-glass" class="size-5" />
          </div>
          <input
            type="text"
            name="search"
            value={@search_query}
            phx-keyup="search"
            phx-key="any"
            placeholder="Buscar por nome da igreja ou cidade..."
            class="input input-bordered w-full pl-10 bg-base-100 border-base-200 text-base-content focus:border-primary focus:ring-primary rounded-xl"
            autocomplete="off"
          />
        </div>

        <%!-- Grid das Igrejas --%>
        <%= if Enum.empty?(@churches) do %>
          <div class="text-center py-12 bg-base-100 rounded-2xl border border-base-200">
            <p class="text-base-content opacity-60">Nenhuma igreja encontrada com o termo pesquisado.</p>
          </div>
        <% else %>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div
              :for={{church, next_event} <- @churches}
              class="card bg-base-100 border border-base-200/80 shadow-sm hover:shadow-md transition-all rounded-2xl overflow-hidden flex flex-col justify-between"
            >
              <div class="p-5">
                <div class="flex items-center gap-3">
                  <div class="p-2.5 bg-primary/10 rounded-xl text-primary shrink-0">
                    <.icon name="hero-home" class="size-6" />
                  </div>
                  <div>
                    <h3 class="font-bold text-base-content text-lg leading-tight">{church.name}</h3>
                    <p class="text-xs opacity-60 mt-0.5">{church.city} - {church.state}</p>
                  </div>
                </div>

                <%!-- Status da Próxima Visita --%>
                <div class="mt-5 pt-4 border-t border-base-100 bg-base-200/20 rounded-xl p-3">
                  <span class="block text-[10px] uppercase font-bold opacity-50 tracking-wider">Próxima Visita Pastoral</span>
                  <div class="flex items-center gap-2 mt-1">
                    <div class={[
                      "size-2 rounded-full shrink-0",
                      next_event && "bg-emerald-500 animate-pulse",
                      !next_event && "bg-base-300"
                    ]} />
                    <span class={[
                      "text-xs font-semibold truncate",
                      next_event && "text-emerald-700 dark:text-emerald-300 font-bold",
                      !next_event && "text-base-content opacity-60"
                    ]}>
                      {format_datetime(next_event)}
                    </span>
                  </div>
                  <span :if={next_event} class="block text-[11px] opacity-70 mt-1 truncate">
                    Evento: {next_event.title}
                  </span>
                </div>
              </div>

              <div class="bg-base-200/30 px-5 py-3 border-t border-base-200/50 flex justify-end">
                <.link
                  navigate={~p"/churches/#{church.id}"}
                  class="btn btn-xs btn-ghost text-primary font-bold hover:bg-primary/10 flex items-center gap-1"
                >
                  Ver Detalhes <span aria-hidden="true">&rarr;</span>
                </.link>
              </div>
            </div>
          </div>
        <% end %>

      </div>
    </Layouts.app>
    """
  end
end
