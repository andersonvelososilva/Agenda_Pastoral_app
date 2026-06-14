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
    {church, upcoming_events} = Churches.get_church_with_upcoming_events!(socket.assigns.church_id)

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
      1 => "Janeiro", 2 => "Fevereiro", 3 => "Março", 4 => "Abril", 5 => "Maio", 6 => "Junho",
      7 => "Julho", 8 => "Agosto", 9 => "Setembro", 10 => "Outubro", 11 => "Novembro", 12 => "Dezembro"
    }
    days = %{
      1 => "Segunda-feira", 2 => "Terça-feira", 3 => "Quarta-feira", 4 => "Quinta-feira",
      5 => "Sexta-feira", 6 => "Sábado", 7 => "Domingo"
    }
    day_of_week = Date.day_of_week(date, :sunday)
    "#{Map.get(days, day_of_week)}, #{date.day} de #{Map.get(months, date.month)} de #{date.year}"
  end

  defp format_time(datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    pad = fn val -> String.pad_leading("#{val}", 2, "0") end
    "#{pad.(local_dt.hour)}:#{pad.(local_dt.minute)}"
  end

  defp translate_priority("urgent"), do: {"Urgente", "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200"}
  defp translate_priority("important"), do: {"Importante", "bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200"}
  defp translate_priority(_), do: {"Normal", "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"}

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
      <div class="space-y-6">
        
        <%!-- Breadcrumbs / Navegação --%>
        <div>
          <.link
            navigate={~p"/churches"}
            class="inline-flex items-center gap-1 text-sm font-semibold text-primary hover:underline"
          >
            <.icon name="hero-arrow-left" class="size-4" /> Voltar para todas as igrejas
          </.link>
        </div>

        <%!-- Cabeçalho da Igreja --%>
        <div class="flex items-center gap-4 py-4 border-b border-base-200">
          <div class="p-3 bg-primary/10 rounded-2xl text-primary">
            <.icon name="hero-home" class="size-8" />
          </div>
          <div>
            <h1 class="text-3xl font-extrabold tracking-tight text-base-content">
              {@church.name}
            </h1>
            <p class="text-sm opacity-60">Cidade: {@church.city} - {@church.state}</p>
          </div>
        </div>

        <%!-- Próxima Visita em Destaque --%>
        <% next_event = List.first(@upcoming_events) %>
        <div class="card bg-gradient-to-br from-emerald-500/10 to-teal-500/10 border border-emerald-500/20 shadow-sm p-6 rounded-2xl">
          <div class="flex items-start gap-4">
            <div class="p-3 bg-emerald-500/10 rounded-xl text-emerald-600 dark:text-emerald-400 mt-0.5 shrink-0">
              <.icon name="hero-calendar-days" class="size-6" />
            </div>
            <div>
              <span class="inline-flex px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/20 text-emerald-800 dark:text-emerald-200">
                Próxima Escala Pastoral
              </span>
              <%= if next_event do %>
                <h3 class="text-xl font-bold mt-2 text-base-content">{next_event.title}</h3>
                <p class="text-sm opacity-70 mt-1 font-medium">{format_datetime(next_event.start_at)}</p>
                <p class="text-xs opacity-60 mt-1">Tipo: {translate_type(next_event.type)}</p>
                <%= if next_event.description && next_event.description != "" do %>
                  <p class="text-sm opacity-80 mt-3 border-l-2 border-emerald-500 pl-3 italic">
                    {next_event.description}
                  </p>
                <% end %>
              <% else %>
                <h3 class="text-xl font-semibold mt-2 text-base-content opacity-70">
                  Sem visitas pastoral programadas
                </h3>
                <p class="text-xs opacity-50 mt-1">Nenhum evento agendado para esta igreja no momento.</p>
              <% end %>
            </div>
          </div>
        </div>

        <%!-- Agenda de Visitas Futuras --%>
        <div>
          <h2 class="text-xl font-bold flex items-center gap-2 mb-4 text-base-content">
            <.icon name="hero-list-bullet" class="size-5 text-primary" />
            Todas as Visitas Agendadas
          </h2>

          <%= if Enum.empty?(@upcoming_events) do %>
            <div class="p-8 bg-base-100 rounded-2xl border border-base-200 text-center opacity-60">
              <p class="text-base-content">Nenhuma visita futura agendada para esta congregação.</p>
            </div>
          <% else %>
            <div class="space-y-4">
              <div :for={event <- @upcoming_events} class="flex items-start gap-4 p-5 bg-base-100 border border-base-200 rounded-2xl shadow-sm">
                <div class="text-center bg-base-200 rounded-xl p-2.5 min-w-16 shrink-0">
                  <% local_dt = DateTime.add(event.start_at, -3, :hour) %>
                  <span class="block text-xs uppercase font-bold opacity-60">
                    {Map.get(%{1 => "Jan", 2 => "Fev", 3 => "Mar", 4 => "Abr", 5 => "Mai", 6 => "Jun", 7 => "Jul", 8 => "Ago", 9 => "Set", 10 => "Out", 11 => "Nov", 12 => "Dez"}, local_dt.month)}
                  </span>
                  <span class="block text-xl font-black">{local_dt.day}</span>
                </div>

                <div class="flex-1 min-w-0">
                  <div class="flex items-center gap-2 flex-wrap">
                    <h3 class="text-lg font-bold text-base-content truncate">{event.title}</h3>
                    <% {p_label, p_class} = translate_priority(event.priority) %>
                    <span class={"px-2.5 py-0.5 text-xs font-semibold rounded-full #{p_class}"}>
                      {p_label}
                    </span>
                  </div>
                  <p class="text-xs opacity-60 mt-1">
                    Horário: {format_time(event.start_at)} às {format_time(event.end_at)}
                    <span class="mx-1.5">•</span>
                    Tipo: {translate_type(event.type)}
                  </p>
                  <%= if event.description && event.description != "" do %>
                    <p class="text-sm opacity-80 mt-2 italic border-l border-primary/20 pl-3">
                      {event.description}
                    </p>
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
