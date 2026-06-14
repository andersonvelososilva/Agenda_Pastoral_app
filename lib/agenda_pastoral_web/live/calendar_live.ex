defmodule AgendaPastoralWeb.CalendarLive do
  use AgendaPastoralWeb, :live_view

  alias AgendaPastoral.Events

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to real-time updates
      Phoenix.PubSub.subscribe(AgendaPastoral.PubSub, "events")
    end

    today = Events.today_br()

    socket =
      socket
      |> assign(
        current_year: today.year,
        current_month: today.month,
        selected_date: today
      )
      |> assign_calendar_data()

    {:ok, socket}
  end

  defp assign_calendar_data(socket) do
    year = socket.assigns.current_year
    month = socket.assigns.current_month

    # Get events for the month
    events = Events.list_events_for_month(year, month)

    # Group events by local date (Brasília UTC-3)
    events_by_date =
      events
      |> Enum.group_by(fn event ->
        DateTime.add(event.start_at, -3, :hour) |> DateTime.to_date()
      end)

    # Build days grid (prev month padding, current, next month padding)
    grid_days = build_grid(year, month)

    assign(socket,
      events: events,
      events_by_date: events_by_date,
      grid_days: grid_days
    )
  end

  @impl true
  def handle_info({_action, _model}, socket) do
    {:noreply, assign_calendar_data(socket)}
  end

  @impl true
  def handle_event("prev_month", _params, socket) do
    {year, month} = prev_month(socket.assigns.current_year, socket.assigns.current_month)

    socket =
      socket
      |> assign(current_year: year, current_month: month)
      |> assign_calendar_data()

    {:noreply, socket}
  end

  @impl true
  def handle_event("next_month", _params, socket) do
    {year, month} = next_month(socket.assigns.current_year, socket.assigns.current_month)

    socket =
      socket
      |> assign(current_year: year, current_month: month)
      |> assign_calendar_data()

    {:noreply, socket}
  end

  @impl true
  def handle_event("go_to_today", _params, socket) do
    today = Events.today_br()

    socket =
      socket
      |> assign(current_year: today.year, current_month: today.month, selected_date: today)
      |> assign_calendar_data()

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_date", %{"date" => date_str}, socket) do
    date = Date.from_iso8601!(date_str)
    {:noreply, assign(socket, selected_date: date)}
  end

  # Helper functions for calendar grid generation
  defp build_grid(year, month) do
    first_day = Date.new!(year, month, 1)
    last_day = Date.new!(year, month, Date.days_in_month(first_day))

    # Day of week of first day (1 = Sunday, 7 = Saturday)
    first_dow = Date.day_of_week(first_day, :sunday)

    # Days to pad at the start (from previous month)
    start_pad = first_dow - 1

    prev_month_days =
      if start_pad > 0 do
        prev_month_date = Date.add(first_day, -1)
        prev_month_days_count = Date.days_in_month(prev_month_date)

        for d <- (prev_month_days_count - start_pad + 1)..prev_month_days_count do
          date = Date.new!(prev_month_date.year, prev_month_date.month, d)
          {date, :prev}
        end
      else
        []
      end

    # Days in current month
    curr_month_days =
      for d <- 1..Date.days_in_month(first_day) do
        date = Date.new!(year, month, d)
        {date, :curr}
      end

    # Total days generated so far
    total_so_far = length(prev_month_days) + length(curr_month_days)

    # Days to pad at the end (from next month)
    end_pad = rem(7 - rem(total_so_far, 7), 7)

    next_month_days =
      if end_pad > 0 do
        next_month_date = Date.add(last_day, 1)

        for d <- 1..end_pad do
          date = Date.new!(next_month_date.year, next_month_date.month, d)
          {date, :next}
        end
      else
        []
      end

    prev_month_days ++ curr_month_days ++ next_month_days
  end

  defp prev_month(year, 1), do: {year - 1, 12}
  defp prev_month(year, month), do: {year, month - 1}

  defp next_month(year, 12), do: {year + 1, 1}
  defp next_month(year, month), do: {year, month + 1}

  # Text Helpers
  defp translate_month(1), do: "Janeiro"
  defp translate_month(2), do: "Fevereiro"
  defp translate_month(3), do: "Março"
  defp translate_month(4), do: "Abril"
  defp translate_month(5), do: "Maio"
  defp translate_month(6), do: "Junho"
  defp translate_month(7), do: "Julho"
  defp translate_month(8), do: "Agosto"
  defp translate_month(9), do: "Setembro"
  defp translate_month(10), do: "Outubro"
  defp translate_month(11), do: "Novembro"
  defp translate_month(12), do: "Dezembro"

  defp format_date_long(date) do
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
    "#{Map.get(days, day_of_week)}, #{date.day} de #{translate_month(date.month)} de #{date.year}"
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
      <div class="space-y-6">
        <%!-- Header do Calendário --%>
        <div class="flex flex-col sm:flex-row justify-between items-center gap-4 py-4 border-b border-base-200">
          <div>
            <h1 class="text-3xl font-extrabold tracking-tight text-base-content text-center sm:text-left">
              Agenda Pastoral
            </h1>
            <p class="text-sm opacity-60 text-center sm:text-left">
              Calendário mensal de visitas e eventos distritais
            </p>
          </div>

          <div class="flex items-center gap-2">
            <button phx-click="prev_month" class="btn btn-sm btn-ghost btn-circle">
              <.icon name="hero-chevron-left" class="size-5" />
            </button>
            <span class="text-lg font-bold min-w-36 text-center">
              {translate_month(@current_month)} de {@current_year}
            </span>
            <button phx-click="next_month" class="btn btn-sm btn-ghost btn-circle">
              <.icon name="hero-chevron-right" class="size-5" />
            </button>
            <button phx-click="go_to_today" class="btn btn-sm btn-primary">
              Hoje
            </button>
          </div>
        </div>

        <%!-- Grid do Calendário --%>
        <div class="bg-base-100 border border-base-200 rounded-2xl overflow-hidden shadow-md">
          <%!-- Cabeçalhos dos dias da semana --%>
          <div class="grid grid-cols-7 border-b border-base-200 bg-base-200/30 text-center py-3 font-semibold text-sm opacity-70">
            <div>DOM</div>
            <div>SEG</div>
            <div>TER</div>
            <div>QUA</div>
            <div>QUI</div>
            <div>SEX</div>
            <div>SÁB</div>
          </div>

          <%!-- Dias --%>
          <div class="grid grid-cols-7 divide-x divide-y divide-base-200 bg-base-100">
            <div
              :for={{date, type} <- @grid_days}
              phx-click="select_date"
              phx-value-date={Date.to_iso8601(date)}
              class={[
                "min-h-16 sm:min-h-24 p-2 cursor-pointer transition-colors relative flex flex-col justify-between hover:bg-primary/5",
                type != :curr && "bg-base-200/50 opacity-40",
                date == @selected_date &&
                  "bg-primary/10 hover:bg-primary/10 border-2 border-primary/50 z-10",
                date == Events.today_br() && "ring-1 ring-secondary"
              ]}
            >
              <%!-- Indicador numérico do dia --%>
              <div class="flex justify-between items-start">
                <span class={[
                  "text-sm font-bold size-6 flex items-center justify-center rounded-full",
                  date == Events.today_br() && "bg-secondary text-secondary-content"
                ]}>
                  {date.day}
                </span>

                <%!-- Indicador de eventos (desktop/badges) --%>
                <% day_events = Map.get(@events_by_date, date, []) %>
                <div :if={!Enum.empty?(day_events)} class="flex gap-1">
                  <span class="size-2 rounded-full bg-primary sm:hidden"></span>
                </div>
              </div>

              <%!-- Lista de eventos para telas grandes --%>
              <div class="hidden sm:block mt-1 space-y-1 overflow-y-auto max-h-16">
                <div
                  :for={event <- Enum.take(day_events, 2)}
                  class={[
                    "text-[10px] px-1.5 py-0.5 rounded font-semibold truncate",
                    event.priority == "urgent" &&
                      "bg-red-100 text-red-800 dark:bg-red-950 dark:text-red-300",
                    event.priority == "important" &&
                      "bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-300",
                    event.priority == "normal" &&
                      "bg-blue-100 text-blue-800 dark:bg-blue-950 dark:text-blue-300"
                  ]}
                  title={"#{format_time(event.start_at)} - #{event.title}"}
                >
                  {format_time(event.start_at)} {event.church.name}
                </div>
                <div :if={length(day_events) > 2} class="text-[9px] text-center opacity-60 font-bold">
                  +{length(day_events) - 2} mais
                </div>
              </div>
            </div>
          </div>
        </div>

        <%!-- Detalhes do Dia Selecionado --%>
        <div class="card bg-base-100 border border-base-200 shadow-lg p-6 rounded-2xl">
          <h2 class="text-xl font-bold flex items-center gap-2 mb-4 text-base-content">
            <.icon name="hero-calendar" class="size-5 text-primary" />
            {format_date_long(@selected_date)}
          </h2>

          <% selected_day_events = Map.get(@events_by_date, @selected_date, []) %>
          <%= if Enum.empty?(selected_day_events) do %>
            <div class="text-center py-8 opacity-60">
              <p class="font-medium text-base-content">
                Nenhuma atividade ou escala pastoral programada para esta data.
              </p>
              <p class="text-xs opacity-60 mt-1">
                Selecione outro dia no calendário para consultar a agenda do pastor.
              </p>
            </div>
          <% else %>
            <div class="space-y-4">
              <div
                :for={event <- selected_day_events}
                class="flex items-start gap-4 p-4 bg-base-200/30 border border-base-200 rounded-xl"
              >
                <div class="p-3 bg-primary/10 rounded-lg text-primary shrink-0">
                  <.icon name="hero-clock" class="size-6" />
                </div>
                <div class="flex-1 min-w-0">
                  <div class="flex items-center gap-2 flex-wrap">
                    <h3 class="text-lg font-bold text-base-content truncate">{event.title}</h3>
                    <% {p_label, p_class} = translate_priority(event.priority) %>
                    <span class={"px-2 py-0.5 text-xs font-semibold rounded-full #{p_class}"}>
                      {p_label}
                    </span>
                  </div>
                  <p class="text-sm font-semibold text-secondary mt-1 flex items-center gap-1">
                    <.icon name="hero-home" class="size-4" />
                    {event.church.name} ({event.church.city} - MA)
                  </p>
                  <p class="text-xs opacity-60 mt-1">
                    Horário: {format_time(event.start_at)} às {format_time(event.end_at)}
                    <span class="mx-1.5">•</span> Tipo: {translate_type(event.type)}
                  </p>
                  <%= if event.description && event.description != "" do %>
                    <p class="text-sm opacity-85 mt-2 bg-base-100 border border-base-200/60 p-3 rounded-lg">
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
