defmodule AgendaPastoralWeb.Admin.AnnouncementLive.Index do
  use AgendaPastoralWeb, :live_view

  alias AgendaPastoral.Announcements
  alias AgendaPastoral.Announcements.Announcement

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AgendaPastoral.PubSub, "announcements")
    end

    socket =
      socket
      |> assign_announcements()

    {:ok, socket}
  end

  defp assign_announcements(socket) do
    assign(socket, :announcements, Announcements.list_announcements())
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo Aviso")
    |> assign(:announcement, %Announcement{})
    |> assign(:changeset, Announcements.change_announcement(%Announcement{}))
    |> assign(:form, to_form(Announcements.change_announcement(%Announcement{})))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    announcement = Announcements.get_announcement!(id)

    socket
    |> assign(:page_title, "Editar Aviso")
    |> assign(:announcement, announcement)
    |> assign(:changeset, Announcements.change_announcement(announcement))
    |> assign(:form, to_form(Announcements.change_announcement(announcement)))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Gerenciar Avisos")
    |> assign(:announcement, nil)
  end

  @impl true
  def handle_info({_action, _model}, socket) do
    {:noreply, assign_announcements(socket)}
  end

  @impl true
  def handle_event("validate", %{"announcement" => announcement_params}, socket) do
    changeset =
      socket.assigns.announcement
      |> Announcements.change_announcement(announcement_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"announcement" => announcement_params}, socket) do
    user = socket.assigns.current_scope.user
    announcement_params = Map.put(announcement_params, "published_by", user.id)

    save_announcement(socket, socket.assigns.live_action, announcement_params)
  end

  def handle_event("delete", %{"id" => id}, socket) do
    announcement = Announcements.get_announcement!(id)
    {:ok, _} = Announcements.delete_announcement(announcement)

    # Broadcast real-time deletion
    Phoenix.PubSub.broadcast(AgendaPastoral.PubSub, "announcements", {:deleted, announcement})

    {:noreply,
     socket
     |> put_flash(:info, "Aviso excluído com sucesso")
     |> assign_announcements()}
  end

  defp save_announcement(socket, :new, announcement_params) do
    case Announcements.create_announcement(announcement_params) do
      {:ok, announcement} ->
        # Broadcast real-time creation
        Phoenix.PubSub.broadcast(AgendaPastoral.PubSub, "announcements", {:created, announcement})

        {:noreply,
         socket
         |> put_flash(:info, "Aviso criado com sucesso")
         |> push_navigate(to: ~p"/admin/announcements")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_announcement(socket, :edit, announcement_params) do
    case Announcements.update_announcement(socket.assigns.announcement, announcement_params) do
      {:ok, announcement} ->
        # Broadcast real-time update
        Phoenix.PubSub.broadcast(AgendaPastoral.PubSub, "announcements", {:updated, announcement})

        {:noreply,
         socket
         |> put_flash(:info, "Aviso atualizado com sucesso")
         |> push_navigate(to: ~p"/admin/announcements")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp format_date(date) do
    local_dt = DateTime.add(date, -3, :hour)
    "#{local_dt.day}/#{String.pad_leading("#{local_dt.month}", 2, "0")}/#{local_dt.year}"
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
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 py-4 border-b border-base-200">
          <div>
            <h1 class="text-3xl font-extrabold text-base-content">
              Gerenciar Avisos
            </h1>
            <p class="text-sm opacity-60">Publique ou edite comunicados e avisos para o distrito</p>
          </div>
          <.link patch={~p"/admin/announcements/new"} class="btn btn-primary btn-sm rounded-xl">
            <.icon name="hero-plus" class="size-4" /> Novo Aviso
          </.link>
        </div>

        <%!-- Lista de Avisos --%>
        <%= if Enum.empty?(@announcements) do %>
          <div class="p-8 bg-base-100 rounded-2xl border border-base-200 text-center">
            <p class="text-base-content opacity-60">Nenhum aviso publicado até o momento.</p>
          </div>
        <% else %>
          <div class="bg-base-100 border border-base-200 rounded-2xl overflow-hidden shadow-sm">
            <div class="overflow-x-auto">
              <table class="table w-full text-base-content">
                <thead>
                  <tr class="bg-base-200/50">
                    <th>Título</th>
                    <th>Publicado por</th>
                    <th>Data</th>
                    <th class="text-right">Ações</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-base-200">
                  <tr :for={announcement <- @announcements} class="hover:bg-base-200/20">
                    <td class="font-bold">{announcement.title}</td>
                    <td>{announcement.publisher.name}</td>
                    <td class="text-xs">{format_date(announcement.inserted_at)}</td>
                    <td class="text-right space-x-2">
                      <.link
                        patch={~p"/admin/announcements/#{announcement.id}/edit"}
                        class="text-primary hover:underline text-xs font-bold"
                      >
                        Editar
                      </.link>
                      <button
                        phx-click="delete"
                        phx-value-id={announcement.id}
                        data-confirm="Deseja realmente excluir este aviso?"
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
          id="announcement-modal"
          show
          on_cancel={JS.patch(~p"/admin/announcements")}
        >
          <.header>
            {@page_title}
            <:subtitle>Preencha os campos abaixo para salvar o comunicado</:subtitle>
          </.header>

          <.form :let={f} for={@form} phx-submit="save" phx-change="validate" class="space-y-4 mt-4">
            <.input field={f[:title]} type="text" label="Título do Aviso" required />
            <.input field={f[:content]} type="textarea" label="Conteúdo do Aviso" rows="5" required />

            <div class="flex justify-end gap-2 pt-4">
              <.button class="btn btn-primary">Salvar Aviso</.button>
            </div>
          </.form>
        </.modal>
      </div>
    </Layouts.app>
    """
  end
end
