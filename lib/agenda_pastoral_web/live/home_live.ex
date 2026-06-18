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

    day_of_week = Date.day_of_week(date)
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
      <div class="space-y-8 max-w-6xl mx-auto animate-fade-in">
        <%!-- Header Distrito --%>
        <div class="relative overflow-hidden p-6 sm:p-8 rounded-3xl bg-gradient-to-r from-primary/10 via-secondary/5 to-transparent border border-base-200/50 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-primary/5 via-transparent to-transparent pointer-events-none" />
          <div class="space-y-2">
            <h1 class="text-3xl sm:text-4xl font-black tracking-tight text-base-content">
              Distrito <span class="text-transparent bg-clip-text bg-gradient-to-r from-primary to-secondary">São João dos Patos</span>
            </h1>
            <p class="text-sm sm:text-base font-semibold opacity-70 tracking-wide">
              Associação Sul Maranhense • Igreja Adventista do Sétimo Dia
            </p>
          </div>
          <a href="/calendar" class="btn btn-primary btn-md shadow-lg shadow-primary/20 self-start md:self-auto gap-2">
            <.icon name="hero-calendar" class="size-4" /> Acessar Agenda Completa
          </a>
        </div>

        <%!-- Seção Onde está o pastor hoje --%>
        <div class="relative overflow-hidden rounded-3xl border border-primary/25 bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 text-slate-100 shadow-2xl">
          <div class="absolute -right-20 -bottom-20 w-80 h-80 rounded-full bg-primary/10 blur-3xl pointer-events-none" />
          <div class="absolute -left-20 -top-20 w-80 h-80 rounded-full bg-secondary/10 blur-3xl pointer-events-none" />
          
          <div class="p-6 sm:p-8 relative">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
              <div class="space-y-2">
                <span class="inline-flex items-center gap-2 px-3 py-1.5 text-[10px] uppercase tracking-wider font-extrabold rounded-full bg-emerald-500/10 border border-emerald-500/25 text-emerald-400">
                  <span class="relative flex h-2.5 w-2.5">
                    <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                    <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
                  </span>
                  Roteiro do Dia
                </span>
                <h2 class="text-2xl sm:text-3xl font-black tracking-tight text-slate-50">Pr. Raimundo Rosendo</h2>
                <p class="text-xs sm:text-sm font-bold text-slate-300 opacity-80 flex items-center gap-1.5">
                  <.icon name="hero-calendar-days" class="size-4 text-primary" /> {format_date(@today_date)}
                </p>
              </div>
            </div>

            <div class="mt-6 border-t border-slate-800/80 pt-6">
              <%= if Enum.empty?(@today_events) do %>
                <div class="text-center py-8 bg-slate-950/45 rounded-2xl border border-slate-800/50">
                  <.icon name="hero-sun" class="size-8 text-primary mx-auto opacity-80" />
                  <p class="text-slate-200 font-bold mt-2">Sem visitas ou reuniões oficiais hoje</p>
                  <p class="text-xs text-slate-400 mt-1">Aproveite para orar pelo ministério pastoral hoje!</p>
                </div>
              <% else %>
                <div class="space-y-4">
                  <div
                    :for={event <- @today_events}
                    class="flex flex-col sm:flex-row items-start gap-4 p-5 bg-slate-950/40 border border-slate-800/60 rounded-2xl shadow-inner hover:border-primary/40 transition-colors"
                  >
                    <div class="p-3 bg-gradient-to-br from-primary/20 to-secondary/10 rounded-xl text-primary border border-primary/20 shadow-md">
                      <.icon name="hero-map-pin" class="size-6" />
                    </div>
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2.5 flex-wrap">
                        <h3 class="text-lg font-black text-slate-50">{event.title}</h3>
                        <% {p_label, p_class} = translate_priority(event.priority) %>
                        <span class={"px-2 py-0.5 text-[9px] uppercase tracking-wider font-extrabold rounded-md #{p_class}"}>
                          {p_label}
                        </span>
                        <span class="px-2 py-0.5 text-[9px] uppercase tracking-wider font-extrabold rounded-md bg-slate-800 text-slate-300">
                          {translate_type(event.type)}
                        </span>
                      </div>
                      <p class="text-sm font-bold text-secondary mt-1.5 flex items-center gap-1">
                        <.icon name="hero-home" class="size-4" />
                        {event.church.name} ({event.church.city} - MA)
                      </p>
                      <p class="text-xs text-slate-400 mt-1.5 flex items-center gap-1">
                        <.icon name="hero-clock" class="size-3.5" />
                        Horário de Início: <span class="text-slate-200 font-bold">{format_time(event.start_at)}</span>
                      </p>
                      <%= if event.description && event.description != "" do %>
                        <div class="text-sm text-slate-300 mt-3 border-l-2 border-primary/50 pl-3 italic bg-slate-900/40 py-2 pr-3 rounded-r-xl">
                          {event.description}
                        </div>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <%!-- Próximos Eventos & Últimos Avisos --%>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <%!-- Card Próximos Eventos --%>
          <div class="bg-base-100 rounded-3xl border border-base-200/60 p-6 shadow-sm flex flex-col justify-between">
            <div>
              <div class="flex justify-between items-center mb-6">
                <h2 class="text-lg font-black flex items-center gap-2 text-base-content">
                  <.icon name="hero-clock" class="size-5 text-primary" /> Agenda Futura
                </h2>
                <a href="/calendar" class="text-xs font-extrabold text-primary hover:underline flex items-center gap-0.5">
                  Ver Calendário <span aria-hidden="true">&rarr;</span>
                </a>
              </div>

              <%= if Enum.empty?(@upcoming_events) do %>
                <div class="p-8 bg-base-200/40 rounded-2xl border border-base-200 border-dashed text-center">
                  <p class="text-base-content opacity-60 font-semibold">Nenhuma programação futura agendada.</p>
                </div>
              <% else %>
                <div class="space-y-3">
                  <div
                    :for={event <- @upcoming_events}
                    class="p-4 bg-base-200/20 hover:bg-base-200/40 border border-base-200/60 rounded-2xl shadow-sm flex items-start gap-4 transition-all duration-200"
                  >
                    <div class="text-center bg-gradient-to-br from-primary/10 to-secondary/5 text-primary rounded-xl p-2.5 min-w-14 border border-primary/10">
                      <span class="block text-[10px] uppercase font-black opacity-75">
                        <% local_dt = DateTime.add(event.start_at, -3, :hour) %>
                        {Map.get(%{1 => "Jan", 2 => "Fev", 3 => "Mar", 4 => "Abr", 5 => "Mai", 6 => "Jun", 7 => "Jul", 8 => "Ago", 9 => "Set", 10 => "Out", 11 => "Nov", 12 => "Dez"}, local_dt.month)}
                      </span>
                      <span class="block text-lg font-black mt-0.5">{local_dt.day}</span>
                    </div>

                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-1.5 flex-wrap">
                        <h3 class="font-extrabold text-base-content truncate">{event.title}</h3>
                        <span class="px-1.5 py-0.5 text-[8px] uppercase tracking-wider font-extrabold rounded bg-base-300 text-base-content/80">
                          {translate_type(event.type)}
                        </span>
                      </div>
                      <p class="text-xs font-bold text-secondary mt-0.5">{event.church.name}</p>
                      <p class="text-[10px] opacity-60 mt-1 flex items-center gap-1">
                        <.icon name="hero-clock" class="size-3" />
                        {format_time(event.start_at)}
                      </p>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <%!-- Card Últimos Avisos --%>
          <div class="bg-base-100 rounded-3xl border border-base-200/60 p-6 shadow-sm">
            <h2 class="text-lg font-black flex items-center gap-2 text-base-content mb-6">
              <.icon name="hero-megaphone" class="size-5 text-primary" /> Quadros de Avisos
            </h2>

            <%= if Enum.empty?(@recent_announcements) do %>
              <div class="p-8 bg-base-200/40 rounded-2xl border border-base-200 border-dashed text-center">
                <p class="text-base-content opacity-60 font-semibold">Nenhum aviso importante publicado.</p>
              </div>
            <% else %>
              <div class="space-y-4">
                <div
                  :for={announcement <- @recent_announcements}
                  class="p-5 bg-base-200/10 hover:bg-base-200/20 border border-base-200/70 rounded-2xl shadow-sm relative overflow-hidden transition-all duration-200"
                >
                  <div class="absolute top-0 left-0 h-full w-1.5 bg-gradient-to-b from-primary to-secondary" />
                  <div class="flex justify-between items-start gap-3">
                    <h3 class="font-black text-base-content text-base">{announcement.title}</h3>
                    <span class="text-[10px] opacity-50 font-bold whitespace-nowrap bg-base-200 px-2 py-0.5 rounded-lg border border-base-300">
                      {format_date(DateTime.to_date(announcement.inserted_at))}
                    </span>
                  </div>
                  <p class="text-xs text-base-content/85 mt-2.5 whitespace-pre-line leading-relaxed">
                    {announcement.content}
                  </p>
                  <div class="mt-4 flex items-center gap-2 text-[10px] font-bold opacity-65">
                    <div class="size-5 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold border border-primary/20">
                      {String.at(announcement.publisher.name, 0)}
                    </div>
                    <span>Distrital • Por: {announcement.publisher.name}</span>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>

        <%!-- Histórico de Alterações --%>
        <div class="bg-base-100 rounded-3xl border border-base-200/60 p-6 shadow-sm">
          <h2 class="text-lg font-black flex items-center gap-2 text-base-content mb-6">
            <.icon name="hero-queue-list" class="size-5 text-primary" /> Histórico de Alterações Públicas
          </h2>

          <%= if Enum.empty?(@recent_alterations) do %>
            <div class="p-8 bg-base-200/40 rounded-2xl border border-base-200 border-dashed text-center">
              <p class="text-base-content opacity-60 font-semibold">Toda a programação segue conforme o previsto.</p>
            </div>
          <% else %>
            <div class="divide-y divide-base-200/60 border border-base-200 rounded-2xl overflow-hidden shadow-inner">
              <div
                :for={alt <- @recent_alterations}
                class="p-4 sm:p-5 flex flex-col sm:flex-row justify-between sm:items-center gap-4 bg-base-100 hover:bg-base-200/20 transition-colors"
              >
                <div class="flex items-start gap-3">
                  <div class="p-2.5 bg-amber-500/10 rounded-xl text-amber-500 mt-0.5 border border-amber-500/20">
                    <.icon name="hero-exclamation-triangle" class="size-4" />
                  </div>
                  <div>
                    <p class="text-sm font-extrabold text-base-content">
                      {alt.description}
                    </p>
                    <p class="text-xs opacity-50 mt-1">
                      Evento original: <span class="font-bold text-base-content/85">{alt.event.title}</span> •
                      Local: <span class="font-bold text-base-content/85">{alt.event.church.name}</span>
                    </p>
                  </div>
                </div>
                <div class="text-left sm:text-right shrink-0 border-t sm:border-t-0 border-base-200 pt-2 sm:pt-0">
                  <span class="block text-[10px] font-bold opacity-60">Registrado por: {alt.user.name}</span>
                  <span class="block text-[9px] opacity-45 mt-0.5">{format_datetime(alt.inserted_at)}</span>
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
