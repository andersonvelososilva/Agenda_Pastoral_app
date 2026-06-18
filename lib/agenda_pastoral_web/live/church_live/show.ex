defmodule AgendaPastoralWeb.ChurchLive.Show do
  use AgendaPastoralWeb, :live_view

  alias AgendaPastoral.Churches

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AgendaPastoral.PubSub, "events")
    end

    socket =
      socket
      |> assign(church_id: id)
      |> assign_church()

    {:ok, socket}
  end

  defp assign_church(socket) do
    # Fetch church and its list of future events
    {church, upcoming_events} =
      Churches.get_church_with_upcoming_events!(socket.assigns.church_id)

    assign(socket,
      church: church,
      upcoming_events: upcoming_events
    )
  end

  @impl true
  def handle_info({_action, _model}, socket) do
    {:noreply, assign_church(socket)}
  end

  # Helpers
  defp format_datetime(datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    date_str = format_date(DateTime.to_date(local_dt))
    time_str = format_time(datetime)
    "#{date_str} às #{time_str}"
  end

  defp format_date(date) do
    months = %{
      1 => "Janeiro",
      2 => "Fevereiro",
      3 => "Março",
      4 => "Abril",
      5 => "Maio",
      6 => "Junho",
      7 => "Julho",
      8 => "Agosto",
      9 => "Setembro",
      10 => "Outubro",
      11 => "Novembro",
      12 => "Dezembro"
    }

    days = %{
      1 => "Segunda-feira",
      2 => "Terça-feira",
      3 => "Quarta-feira",
      4 => "Quinta-feira",
      5 => "Sexta-feira",
      6 => "Sábado",
      7 => "Domingo"
    }

    day_of_week = Date.day_of_week(date, :sunday)
    "#{Map.get(days, day_of_week)}, #{date.day} de #{Map.get(months, date.month)} de #{date.year}"
  end

  defp format_time(datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    pad = fn val -> String.pad_leading("#{val}", 2, "0") end
    "#{pad.(local_dt.hour)}:#{pad.(local_dt.minute)}"
  end

  defp translate_priority("urgent"),
    do: {"Urgente", "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200"}

  defp translate_priority("important"),
    do: {"Importante", "bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200"}

  defp translate_priority(_),
    do: {"Normal", "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"}

  defp translate_type("culto_divino"), do: "Culto Divino"
  defp translate_type("santa_ceia"), do: "Santa Ceia"
  defp translate_type("batismo"), do: "Batismo"
  defp translate_type("semana_oracao"), do: "Semana de Oração"
  defp translate_type("reuniao_adm"), do: "Reunião Administrativa"
  defp translate_type("evangelismo"), do: "Evangelismo"
  defp translate_type("treinamento"), do: "Treinamento"
  defp translate_type("congresso"), do: "Congresso"
  defp translate_type(other), do: other

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6 max-w-6xl mx-auto animate-fade-in">
        <%!-- Breadcrumbs / Navegação --%>
        <div>
          <.link
            navigate={~p"/churches"}
            class="inline-flex items-center gap-1.5 text-xs font-black uppercase tracking-wider text-primary hover:underline bg-primary/10 px-3 py-1.5 rounded-lg transition-colors"
          >
            <.icon name="hero-arrow-left" class="size-3.5" /> Voltar para todas as igrejas
          </.link>
        </div>

        <%!-- Cabeçalho da Igreja --%>
        <div class="flex items-center gap-4 py-4 border-b border-base-200/50">
          <div class="p-3 bg-gradient-to-br from-primary/10 to-secondary/5 text-primary rounded-2xl border border-primary/10">
            <.icon name="hero-home" class="size-8" />
          </div>
          <div>
            <h1 class="text-3xl font-black tracking-tight text-base-content">
              {@church.name}
            </h1>
            <p class="text-xs sm:text-sm font-bold opacity-60 uppercase tracking-wider mt-1">Localidade: {@church.city} - {@church.state}</p>
          </div>
        </div>

        <%!-- Próxima Visita em Destaque --%>
        <% next_event = List.first(@upcoming_events) %>
        <div class="relative overflow-hidden rounded-3xl border border-emerald-500/25 bg-gradient-to-br from-emerald-500/10 to-teal-500/10 shadow-sm p-6 sm:p-8">
          <div class="absolute -right-10 -bottom-10 w-40 h-40 rounded-full bg-emerald-500/10 blur-2xl pointer-events-none" />
          <div class="flex items-start gap-4 relative">
            <div class="p-3 bg-emerald-500/10 rounded-xl text-emerald-600 dark:text-emerald-400 mt-0.5 shrink-0 border border-emerald-500/20">
              <.icon name="hero-calendar-days" class="size-6" />
            </div>
            <div class="space-y-2 flex-1 min-w-0">
              <span class="inline-flex px-2.5 py-1 rounded-full text-[9px] uppercase tracking-wider font-extrabold bg-emerald-500/20 text-emerald-800 dark:text-emerald-200">
                Próxima Visita Pastoral
              </span>
              <%= if next_event do %>
                <h3 class="text-xl sm:text-2xl font-black text-base-content">{next_event.title}</h3>
                <p class="text-xs sm:text-sm opacity-80 font-bold text-base-content flex items-center gap-1">
                  <.icon name="hero-clock" class="size-3.5" />
                  {format_datetime(next_event.start_at)}
                </p>
                <p class="text-[10px] uppercase font-bold tracking-wider opacity-60 mt-1">Tipo: {translate_type(next_event.type)}</p>
                <%= if next_event.description && next_event.description != "" do %>
                  <div class="text-xs sm:text-sm text-base-content/85 mt-3 border-l-2 border-emerald-500/50 pl-3 italic bg-base-100/50 p-3 rounded-r-xl">
                    {next_event.description}
                  </div>
                <% end %>
              <% else %>
                <h3 class="text-lg font-bold text-base-content/70">
                  Sem visitas pastorais programadas
                </h3>
                <p class="text-xs opacity-50 mt-1">
                  Nenhum evento agendado para esta igreja no momento.
                </p>
              <% end %>
            </div>
          </div>
        </div>

        <%!-- Agenda de Visitas Futuras --%>
        <div class="bg-base-100 rounded-3xl border border-base-200/60 p-6 shadow-sm">
          <h2 class="text-lg font-black flex items-center gap-2 mb-6 text-base-content">
            <.icon name="hero-list-bullet" class="size-5 text-primary" /> Todas as Visitas Agendadas
          </h2>

          <%= if Enum.empty?(@upcoming_events) do %>
            <div class="p-8 bg-base-200/40 rounded-2xl border border-base-200 border-dashed text-center opacity-60">
              <p class="text-base-content font-bold">Nenhuma visita futura agendada para esta congregação.</p>
            </div>
          <% else %>
            <div class="space-y-4">
              <div
                :for={event <- @upcoming_events}
                class="flex flex-col sm:flex-row items-start gap-4 p-5 bg-base-200/10 hover:bg-base-200/25 border border-base-200/70 rounded-2xl transition-all duration-200"
              >
                <div class="text-center bg-gradient-to-br from-primary/10 to-secondary/5 text-primary rounded-xl p-2.5 min-w-16 shrink-0 border border-primary/10">
                  <% local_dt = DateTime.add(event.start_at, -3, :hour) %>
                  <span class="block text-[10px] uppercase font-black opacity-75">
                    {Map.get(
                      %{
                        1 => "Jan",
                        2 => "Fev",
                        3 => "Mar",
                        4 => "Abr",
                        5 => "Mai",
                        6 => "Jun",
                        7 => "Jul",
                        8 => "Ago",
                        9 => "Set",
                        10 => "Out",
                        11 => "Nov",
                        12 => "Dez"
                      },
                      local_dt.month
                    )}
                  </span>
                  <span class="block text-xl font-black mt-0.5">{local_dt.day}</span>
                </div>

                <div class="flex-1 min-w-0 space-y-1">
                  <div class="flex items-center gap-2 flex-wrap">
                    <h3 class="text-base font-black text-base-content truncate">{event.title}</h3>
                    <% {p_label, p_class} = translate_priority(event.priority) %>
                    <span class={"px-2 py-0.5 text-[8px] uppercase tracking-wider font-extrabold rounded-md #{p_class}"}>
                      {p_label}
                    </span>
                    <span class="px-2 py-0.5 text-[8px] uppercase tracking-wider font-extrabold rounded-md bg-base-300 text-base-content/85">
                      {translate_type(event.type)}
                    </span>
                  </div>
                  <p class="text-xs opacity-60 mt-1.5 flex items-center gap-1">
                    <.icon name="hero-clock" class="size-3.5" />
                    Horário: <span class="font-semibold text-base-content/80">{format_time(event.start_at)} às {format_time(event.end_at)}</span>
                  </p>
                  <%= if event.description && event.description != "" do %>
                    <div class="text-xs sm:text-sm text-base-content/85 mt-3 bg-base-100 border border-base-200/60 p-3 rounded-xl">
                      {event.description}
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
