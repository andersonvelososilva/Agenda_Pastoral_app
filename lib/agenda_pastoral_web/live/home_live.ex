defmodule AgendaPastoralWeb.HomeLive do
  use AgendaPastoralWeb, :live_view

  alias AgendaPastoral.Events
  alias AgendaPastoral.Announcements
  alias AgendaPastoral.Alterations

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to real-time updates using Phoenix PubSub
      Phoenix.PubSub.subscribe(AgendaPastoral.PubSub, "events")
      Phoenix.PubSub.subscribe(AgendaPastoral.PubSub, "announcements")
      Phoenix.PubSub.subscribe(AgendaPastoral.PubSub, "alterations")
    end

    {:ok, assign_data(socket)}
  end

  defp assign_data(socket) do
    assign(socket,
      today_events: Events.list_today_events(),
      upcoming_events: Events.list_upcoming_events(5),
      recent_announcements: Announcements.list_recent_announcements(3),
      recent_alterations: Alterations.list_recent_alterations(5),
      today_date: Events.today_br()
    )
  end

  @impl true
  def handle_info({_action, _model}, socket) do
    # When updates are broadcast, refresh dashboard data
    {:noreply, assign_data(socket)}
  end

  # Helper functions for formatting in HEEx templates
  defp format_date(date) do
    days = %{
      1 => "Segunda-feira",
      2 => "Terça-feira",
      3 => "Quarta-feira",
      4 => "Quinta-feira",
      5 => "Sexta-feira",
      6 => "Sábado",
      7 => "Domingo"
    }

    months = %{
      1 => "janeiro",
      2 => "fevereiro",
      3 => "março",
      4 => "abril",
      5 => "maio",
      6 => "junho",
      7 => "julho",
      8 => "agosto",
      9 => "setembro",
      10 => "outubro",
      11 => "novembro",
      12 => "dezembro"
    }

    day_of_week = Calendar.ISO.day_of_week(date.year, date.month, date.day)
    "#{Map.get(days, day_of_week)}, #{date.day} de #{Map.get(months, date.month)} de #{date.year}"
  end

  defp format_time(datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    pad = fn val -> String.pad_leading("#{val}", 2, "0") end
    "#{pad.(local_dt.hour)}:#{pad.(local_dt.minute)}"
  end

  defp format_datetime(datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    date_str = format_date(DateTime.to_date(local_dt))
    time_str = format_time(datetime)
    "#{date_str} às #{time_str}"
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
      <div class="space-y-8 animate-fade-in">
        
        <%!-- Header Distrito --%>
        <div class="text-center md:text-left py-6 border-b border-base-200">
          <h1 class="text-3xl font-extrabold tracking-tight md:text-4xl text-base-content">
            Agenda Pastoral Digital
          </h1>
          <p class="mt-2 text-lg text-base-content opacity-70">
            Distrito de São João dos Patos • Associação Sul Maranhense
          </p>
        </div>

        <%!-- Seção Onde está o pastor hoje --%>
        <div class="card bg-gradient-to-br from-primary/10 to-secondary/10 border border-primary/20 shadow-xl overflow-hidden rounded-2xl">
          <div class="p-6 sm:p-8">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
              <div>
                <span class="inline-flex items-center gap-1.5 px-3 py-1 text-xs font-semibold rounded-full bg-primary/20 text-primary">
                  <.icon name="hero-map-pin" class="size-3.5" /> Onde está o pastor hoje?
                </span>
                <h2 class="text-2xl font-bold mt-2 text-base-content">Pr. Raimundo Rosendo</h2>
                <p class="text-sm opacity-60 mt-1">{format_date(@today_date)}</p>
              </div>
            </div>

            <div class="mt-6 border-t border-base-200/55 pt-6">
              <%= if Enum.empty?(@today_events) do %>
                <div class="text-center py-6">
                  <p class="text-base-content opacity-60 font-medium">Sem programação cadastrada para hoje.</p>
                  <p class="text-xs opacity-40 mt-1">Aproveite para orar pelo ministério pastoral hoje!</p>
                </div>
              <% else %>
                <div class="space-y-4">
                  <div :for={event <- @today_events} class="flex items-start gap-4 p-4 bg-base-100 rounded-xl border border-base-200 shadow-sm hover:shadow-md transition-shadow">
                    <div class="p-3 bg-primary/10 rounded-lg text-primary">
                      <.icon name="hero-calendar-days" class="size-6" />
                    </div>
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2 flex-wrap">
                        <h3 class="text-lg font-bold text-base-content truncate">{event.title}</h3>
                        <% {p_label, p_class} = translate_priority(event.priority) %>
                        <span class={"px-2.5 py-0.5 text-xs font-semibold rounded-full #{p_class}"}>
                          {p_label}
                        </span>
                      </div>
                      <p class="text-sm font-semibold text-secondary mt-1 flex items-center gap-1">
                        <.icon name="hero-home" class="size-4" />
                        {event.church.name} ({event.church.city} - MA)
                      </p>
                      <p class="text-xs opacity-60 mt-1 flex items-center gap-1">
                        <.icon name="hero-clock" class="size-3.5" />
                        {format_time(event.start_at)}
                        <span class="mx-1">•</span>
                        {translate_type(event.type)}
                      </p>
                      <%= if event.description && event.description != "" do %>
                        <p class="text-sm opacity-80 mt-2 border-l-2 border-primary/30 pl-3 italic">
                          {event.description}
                        </p>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <%!-- Próximos Eventos --%>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div>
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-bold flex items-center gap-2 text-base-content">
                <.icon name="hero-clock" class="size-5 text-primary" /> Próximos Eventos
              </h2>
              <a href="/calendar" class="text-sm font-semibold text-primary hover:underline flex items-center gap-1">
                Ver todos <span aria-hidden="true">&rarr;</span>
              </a>
            </div>

            <%= if Enum.empty?(@upcoming_events) do %>
              <div class="p-8 bg-base-100 rounded-2xl border border-base-200 text-center">
                <p class="text-base-content opacity-60">Nenhum evento futuro programado.</p>
              </div>
            <% else %>
              <div class="space-y-3">
                <div :for={event <- @upcoming_events} class="p-4 bg-base-100 rounded-xl border border-base-200 shadow-sm flex items-start gap-4">
                  <div class="text-center bg-base-200 rounded-lg p-2 min-w-16">
                    <span class="block text-xs uppercase font-bold opacity-60">
                      <%# Show abbreviated day / month %>
                      <% local_dt = DateTime.add(event.start_at, -3, :hour) %>
                      {Map.get(%{1 => "Jan", 2 => "Fev", 3 => "Mar", 4 => "Abr", 5 => "Mai", 6 => "Jun", 7 => "Jul", 8 => "Ago", 9 => "Set", 10 => "Out", 11 => "Nov", 12 => "Dez"}, local_dt.month)}
                    </span>
                    <span class="block text-xl font-black">{local_dt.day}</span>
                  </div>

                  <div class="flex-1 min-w-0">
                    <h3 class="font-bold text-base-content truncate">{event.title}</h3>
                    <p class="text-sm font-semibold text-secondary mt-0.5">{event.church.name}</p>
                    <p class="text-xs opacity-60 mt-1">
                      {format_time(event.start_at)} • {translate_type(event.type)}
                    </p>
                  </div>
                </div>
              </div>
            <% end %>
          </div>

          <%!-- Últimos Avisos --%>
          <div>
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-bold flex items-center gap-2 text-base-content">
                <.icon name="hero-megaphone" class="size-5 text-primary" /> Últimos Avisos
              </h2>
            </div>

            <%= if Enum.empty?(@recent_announcements) do %>
              <div class="p-8 bg-base-100 rounded-2xl border border-base-200 text-center">
                <p class="text-base-content opacity-60">Nenhum aviso publicado recentemente.</p>
              </div>
            <% else %>
              <div class="space-y-4">
                <div :for={announcement <- @recent_announcements} class="p-5 bg-base-100 rounded-2xl border border-base-200 shadow-sm relative overflow-hidden">
                  <div class="absolute top-0 left-0 h-full w-1.5 bg-primary" />
                  <div class="flex justify-between items-start gap-2">
                    <h3 class="font-bold text-base-content text-lg">{announcement.title}</h3>
                    <span class="text-xs opacity-50 whitespace-nowrap">
                      {format_date(DateTime.to_date(announcement.inserted_at))}
                    </span>
                  </div>
                  <p class="text-sm text-base-content opacity-85 mt-2 whitespace-pre-line">
                    {announcement.content}
                  </p>
                  <div class="mt-4 flex items-center gap-2 text-xs opacity-65">
                    <div class="size-5 rounded-full bg-base-300 flex items-center justify-center font-bold">
                      {String.at(announcement.publisher.name, 0)}
                    </div>
                    <span>Publicado por: {announcement.publisher.name}</span>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>

        <%!-- Histórico de Alterações --%>
        <div class="pt-4">
          <h2 class="text-xl font-bold flex items-center gap-2 mb-4 text-base-content">
            <.icon name="hero-queue-list" class="size-5 text-primary" /> Alterações Recentes na Agenda
          </h2>

          <%= if Enum.empty?(@recent_alterations) do %>
            <div class="p-6 bg-base-100 rounded-2xl border border-base-200 text-center">
              <p class="text-base-content opacity-60">Nenhuma alteração registrada recentemente.</p>
            </div>
          <% else %>
            <div class="bg-base-100 border border-base-200 rounded-2xl overflow-hidden shadow-sm">
              <div class="divide-y divide-base-200">
                <div :for={alt <- @recent_alterations} class="p-4 sm:p-5 flex flex-col sm:flex-row justify-between sm:items-center gap-3">
                  <div class="flex items-start gap-3">
                    <div class="p-2 bg-amber-500/10 rounded-lg text-amber-500 mt-0.5">
                      <.icon name="hero-exclamation-triangle" class="size-5" />
                    </div>
                    <div>
                      <p class="text-sm font-semibold text-base-content">
                        {alt.description}
                      </p>
                      <p class="text-xs opacity-50 mt-1">
                        Evento: <span class="font-semibold">{alt.event.title}</span> •
                        Igreja: <span class="font-semibold">{alt.event.church.name}</span>
                      </p>
                    </div>
                  </div>
                  <div class="text-left sm:text-right shrink-0">
                    <span class="block text-xs opacity-60">Por: {alt.user.name}</span>
                    <span class="block text-xs opacity-45 mt-0.5">{format_datetime(alt.inserted_at)}</span>
                  </div>
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
