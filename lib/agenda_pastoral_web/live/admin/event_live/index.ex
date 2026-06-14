defmodule AgendaPastoralWeb.Admin.EventLive.Index do
  use AgendaPastoralWeb, :live_view

  alias AgendaPastoral.Events
  alias AgendaPastoral.Events.Event
  alias AgendaPastoral.Churches
  alias AgendaPastoral.Alterations

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AgendaPastoral.PubSub, "events")
    end

    churches = Churches.list_churches()

    socket =
      socket
      |> assign(:churches, churches)
      |> assign_events()

    {:ok, socket}
  end

  defp assign_events(socket) do
    assign(socket, :events, Events.list_events())
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo Evento")
    |> assign(:event, %Event{})
    |> assign(:changeset, Events.change_event(%Event{}))
    |> assign(:form, to_form(Events.change_event(%Event{})))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    event = Events.get_event!(id)

    socket
    |> assign(:page_title, "Editar Evento")
    |> assign(:event, event)
    |> assign(:changeset, Events.change_event(event))
    |> assign(:form, to_form(Events.change_event(event)))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Gerenciar Eventos")
    |> assign(:event, nil)
  end

  @impl true
  def handle_info({_action, _model}, socket) do
    {:noreply, assign_events(socket)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    # Handle datetime conversion for validations
    event_params = parse_datetimes(event_params)

    changeset =
      socket.assigns.event
      |> Events.change_event(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    user = socket.assigns.current_scope.user

    event_params =
      event_params
      |> parse_datetimes()
      |> Map.put("created_by", user.id)

    save_event(socket, socket.assigns.live_action, event_params)
  end

  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(id)
    user = socket.assigns.current_scope.user

    {:ok, _deleted_event} = Events.delete_event(event)

    # Log deletion in Alterations
    description = "Evento '#{event.title}' excluído da agenda."

    {:ok, _} =
      Alterations.create_alteration(%{
        event_id: event.id,
        user_id: user.id,
        description: description
      })

    # Broadcast changes to real-time clients
    Phoenix.PubSub.broadcast(AgendaPastoral.PubSub, "events", {:deleted, event})
    Phoenix.PubSub.broadcast(AgendaPastoral.PubSub, "alterations", {:created, %{}})

    {:noreply,
     socket
     |> put_flash(:info, "Evento excluído com sucesso")
     |> assign_events()}
  end

  defp save_event(socket, :new, event_params) do
    case Events.create_event(event_params) do
      {:ok, event} ->
        # Broadcast real-time update
        Phoenix.PubSub.broadcast(AgendaPastoral.PubSub, "events", {:created, event})

        {:noreply,
         socket
         |> put_flash(:info, "Evento criado com sucesso")
         |> push_navigate(to: ~p"/admin/events")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_event(socket, :edit, event_params) do
    old_event = socket.assigns.event
    user = socket.assigns.current_scope.user

    case Events.update_event(old_event, event_params) do
      {:ok, event} ->
        # Log modifications in Alterations table
        log_modifications(old_event, event, user, event_params["change_reason"] || "")

        # Broadcast real-time update
        Phoenix.PubSub.broadcast(AgendaPastoral.PubSub, "events", {:updated, event})
        Phoenix.PubSub.broadcast(AgendaPastoral.PubSub, "alterations", {:created, %{}})

        {:noreply,
         socket
         |> put_flash(:info, "Evento atualizado com sucesso")
         |> push_navigate(to: ~p"/admin/events")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp log_modifications(old_event, new_event, user, change_reason) do
    changes = []

    # Check Church change
    changes =
      if old_event.church_id != new_event.church_id do
        old_c = Churches.get_church!(old_event.church_id)
        new_c = Churches.get_church!(new_event.church_id)
        ["Igreja alterada de '#{old_c.name}' para '#{new_c.name}'" | changes]
      else
        changes
      end

    # Check Date/Time change
    changes =
      if old_event.start_at != new_event.start_at do
        ["Horário/Data reprogramada" | changes]
      else
        changes
      end

    # Check Status change
    changes =
      if old_event.status != new_event.status do
        ["Status alterado para '#{new_event.status}'" | changes]
      else
        changes
      end

    # Build description
    desc_prefix =
      if Enum.empty?(changes), do: "Programação editada", else: Enum.join(changes, ", ")

    motivo = if change_reason != "", do: ". Motivo: #{change_reason}", else: ""
    description = "#{desc_prefix}#{motivo}."

    {:ok, _} =
      Alterations.create_alteration(%{
        event_id: new_event.id,
        user_id: user.id,
        description: description
      })
  end

  # Helper to parse datetime input values into UTC datetimes
  defp parse_datetimes(params) do
    params
    |> parse_datetime("start_at")
    |> parse_datetime("end_at")
  end

  defp parse_datetime(params, key) do
    case Map.get(params, key) do
      nil ->
        params

      "" ->
        params

      value when is_binary(value) ->
        # datetime-local inputs send: "YYYY-MM-DDTHH:MM"
        case DateTime.from_iso8601(value <> ":00Z") do
          {:ok, datetime, _offset} ->
            # Shift back by +3 hours to match Brasília time offset to UTC
            utc_datetime = DateTime.add(datetime, 3, :hour)
            Map.put(params, key, utc_datetime)

          _ ->
            params
        end

      _ ->
        params
    end
  end

  # Helpers
  defp format_datetime(datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    pad = fn val -> String.pad_leading("#{val}", 2, "0") end

    "#{local_dt.day}/#{String.pad_leading("#{local_dt.month}", 2, "0")}/#{local_dt.year} às #{pad.(local_dt.hour)}:#{pad.(local_dt.minute)}"
  end

  defp translate_type("culto_divino"), do: "Culto Divino"
  defp translate_type("santa_ceia"), do: "Santa Ceia"
  defp translate_type("batismo"), do: "Batismo"
  defp translate_type("semana_oracao"), do: "Semana de Oração"
  defp translate_type("reuniao_adm"), do: "Reunião Administrativa"
  defp translate_type("evangelismo"), do: "Evangelismo"
  defp translate_type("treinamento"), do: "Treinamento"
  defp translate_type("congresso"), do: "Congresso"
  defp translate_type(other), do: other

  defp format_datetime_local(nil), do: ""

  defp format_datetime_local(%DateTime{} = datetime) do
    local_dt = DateTime.add(datetime, -3, :hour)
    pad = fn val -> String.pad_leading("#{val}", 2, "0") end

    "#{local_dt.year}-#{pad.(local_dt.month)}-#{pad.(local_dt.day)}T#{pad.(local_dt.hour)}:#{pad.(local_dt.minute)}"
  end

  defp format_datetime_local(value), do: value

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
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 py-4 border-b border-base-200">
          <div>
            <h1 class="text-3xl font-extrabold text-base-content">
              Gerenciar Eventos
            </h1>
            <p class="text-sm opacity-60">
              Adicione, edite ou cancele programações da agenda pastoral
            </p>
          </div>
          <.link patch={~p"/admin/events/new"} class="btn btn-primary btn-sm rounded-xl">
            <.icon name="hero-plus" class="size-4" /> Novo Evento
          </.link>
        </div>

        <%!-- Lista de Eventos --%>
        <%= if Enum.empty?(@events) do %>
          <div class="p-8 bg-base-100 rounded-2xl border border-base-200 text-center">
            <p class="text-base-content opacity-60">Nenhum evento cadastrado.</p>
          </div>
        <% else %>
          <div class="bg-base-100 border border-base-200 rounded-2xl overflow-hidden shadow-sm">
            <div class="overflow-x-auto">
              <table class="table w-full text-base-content">
                <thead>
                  <tr class="bg-base-200/50">
                    <th>Título</th>
                    <th>Igreja</th>
                    <th>Data & Horário</th>
                    <th>Tipo</th>
                    <th>Status</th>
                    <th class="text-right">Ações</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-base-200">
                  <tr :for={event <- @events} class="hover:bg-base-200/20">
                    <td class="font-bold">{event.title}</td>
                    <td>{event.church.name}</td>
                    <td class="text-xs">{format_datetime(event.start_at)}</td>
                    <td class="text-xs">{translate_type(event.type)}</td>
                    <td>
                      <span class={[
                        "px-2 py-0.5 text-xs font-semibold rounded-full",
                        event.status == "scheduled" && "bg-emerald-100 text-emerald-800",
                        event.status == "changed" && "bg-amber-100 text-amber-800",
                        event.status == "cancelled" && "bg-rose-100 text-rose-800"
                      ]}>
                        {event.status}
                      </span>
                    </td>
                    <td class="text-right space-x-2">
                      <.link
                        patch={~p"/admin/events/#{event.id}/edit"}
                        class="text-primary hover:underline text-xs font-bold"
                      >
                        Editar
                      </.link>
                      <button
                        phx-click="delete"
                        phx-value-id={event.id}
                        data-confirm="Deseja realmente excluir este evento?"
                        class="text-error hover:underline text-xs font-bold"
                      >
                        Excluir
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        <% end %>

        <%!-- Modal de Formulário --%>
        <.modal
          :if={@live_action in [:new, :edit]}
          id="event-modal"
          show
          on_cancel={JS.patch(~p"/admin/events")}
        >
          <.header>
            {@page_title}
            <:subtitle>Preencha os campos abaixo para salvar a escala pastoral</:subtitle>
          </.header>

          <.form :let={f} for={@form} phx-submit="save" phx-change="validate" class="space-y-4 mt-4">
            <.input field={f[:title]} type="text" label="Título do Evento" required />
            <.input field={f[:description]} type="textarea" label="Descrição / Notas" />

            <.input
              field={f[:church_id]}
              type="select"
              label="Igreja"
              options={Enum.map(@churches, &{&1.name, &1.id})}
              required
            />

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <.input
                field={f[:start_at]}
                type="datetime-local"
                label="Início do Evento"
                value={format_datetime_local(f[:start_at].value)}
                required
              />
              <.input
                field={f[:end_at]}
                type="datetime-local"
                label="Fim do Evento"
                value={format_datetime_local(f[:end_at].value)}
                required
              />
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <.input
                field={f[:type]}
                type="select"
                label="Tipo"
                options={[
                  {"Culto Divino", "culto_divino"},
                  {"Santa Ceia", "santa_ceia"},
                  {"Batismo", "batismo"},
                  {"Semana de Oração", "semana_oracao"},
                  {"Reunião Administrativa", "reuniao_adm"},
                  {"Evangelismo", "evangelismo"},
                  {"Treinamento", "treinamento"},
                  {"Congresso", "congresso"}
                ]}
                required
              />

              <.input
                field={f[:priority]}
                type="select"
                label="Prioridade"
                options={[
                  {"Normal", "normal"},
                  {"Importante", "important"},
                  {"Urgente", "urgent"}
                ]}
                required
              />

              <.input
                field={f[:status]}
                type="select"
                label="Status"
                options={[
                  {"Agendado (Scheduled)", "scheduled"},
                  {"Alterado (Changed)", "changed"},
                  {"Cancelado (Cancelled)", "cancelled"}
                ]}
                required
              />
            </div>

            <%!-- Reason for change (required for edits) --%>
            <div
              :if={@live_action == :edit}
              class="p-4 bg-amber-500/10 rounded-xl border border-amber-500/20 space-y-2"
            >
              <span class="text-xs font-bold text-amber-700 dark:text-amber-300">Registro de Histórico</span>
              <.input
                field={f[:change_reason]}
                type="textarea"
                label="Motivo da Alteração (Será registrado no histórico público)"
                placeholder="Ex: Reunião de emergência, alteração de local por logística..."
              />
            </div>

            <div class="flex justify-end gap-2 pt-4">
              <.button class="btn btn-primary">Salvar Evento</.button>
            </div>
          </.form>
        </.modal>
      </div>
    </Layouts.app>
    """
  end
end
