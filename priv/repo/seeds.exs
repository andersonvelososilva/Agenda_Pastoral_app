# Script for populating the database.
alias AgendaPastoral.Repo
alias AgendaPastoral.Accounts.User
alias AgendaPastoral.Districts.District
alias AgendaPastoral.Churches.Church
alias AgendaPastoral.Events.Event

# Import Ecto Query for cleaning up
import Ecto.Query

# 1. Create Users (Pastor and Admin)
IO.puts("Seeding Users...")
pastor_email = "pastor@iasd.org"
admin_email = "admin@iasd.org"

pastor =
  case Repo.get_by(User, email: pastor_email) do
    nil ->
      {:ok, user} =
        AgendaPastoral.Accounts.register_user(%{
          email: pastor_email,
          name: "Pr. Raimundo Rosendo",
          role: "pastor",
          password: "password123456"
        })

      # Auto-confirm the user email
      {:ok, user} = Repo.update(User.confirm_changeset(user))
      user

    user ->
      user
  end

_admin =
  case Repo.get_by(User, email: admin_email) do
    nil ->
      {:ok, user} =
        AgendaPastoral.Accounts.register_user(%{
          email: admin_email,
          name: "Administrador",
          role: "admin",
          password: "admin12345678"
        })

      {:ok, user} = Repo.update(User.confirm_changeset(user))
      user

    user ->
      user
  end

# 2. Create District
IO.puts("Seeding District...")
district_name = "Distrito São João dos Patos"

district =
  case Repo.get_by(District, name: district_name) do
    nil ->
      Repo.insert!(%District{
        name: district_name,
        pastor_name: "Pr. Raimundo Rosendo",
        active: true
      })

    district ->
      district
  end

# 3. Create Churches
IO.puts("Seeding Churches...")

churches_data = [
  {"Bairro Maria", "Pastos Bons"},
  {"Nova Canaã", "São João dos Patos"},
  {"Central São João dos Patos", "São João dos Patos"},
  {"Nova Jerusalém", "Pastos Bons"},
  {"Várzea", "Sucupira do Norte"},
  {"Pastos Bons", "Pastos Bons"},
  {"Residencial", "Paraibano"},
  {"Central Barão de Grajaú", "Barão de Grajaú"},
  {"Nova Iorque", "Nova Iorque"},
  {"São Francisco do Maranhão", "São Francisco do Maranhão"},
  {"Sucupira do Norte", "Sucupira do Norte"},
  {"Sucupira do Riachão", "Sucupira do Riachão"},
  {"Olaria", "São João dos Patos"},
  {"Novo Éden", "Sucupira do Norte"},
  {"Eldorado", "Barão de Grajaú"}
]

churches =
  for {name, city} <- churches_data do
    case Repo.get_by(Church, name: name, district_id: district.id) do
      nil ->
        Repo.insert!(%Church{
          name: name,
          city: city,
          state: "MA",
          active: true,
          district_id: district.id
        })

      church ->
        church
    end
  end

# 4. Cleanup existing events to allow clean re-seeding
IO.puts("Cleaning up old events & alterations...")
Repo.delete_all(AgendaPastoral.Alterations.Alteration)
Repo.delete_all(Event)

# 5. Populate random events for the next 30 days
IO.puts("Generating simulation events for the next 30 days...")

event_types = [
  {"culto_divino", "Culto Divino", ["Sábado de Adoração", "Culto de Pregação", "Santa Liturgia"], ["normal", "normal", "important"]},
  {"santa_ceia", "Santa Ceia", ["Santa Ceia do Senhor", "Comunhão e Lava-Pés"], ["important", "urgent"]},
  {"batismo", "Cerimônia de Batismo", ["Grande Batismo Distrital", "Festa Nas Águas"], ["urgent", "important"]},
  {"semana_oracao", "Semana de Oração", ["Semana Jovem", "Semana de Mordomia", "Reavivamento Espiritual"], ["important", "important"]},
  {"reuniao_adm", "Reunião de Comissão", ["Comissão do Distrito", "Comissão Regular", "Reunião de Anciãos"], ["normal", "important"]},
  {"evangelismo", "Evangelismo Público", ["Campanha de Colheita", "Impacto Esperança", "Evangelismo de Bairro"], ["important", "normal"]},
  {"treinamento", "Treinamento Distrital", ["Capacitação de Líderes", "Treinamento de Escola Sabatina"], ["normal", "normal"]},
  {"congresso", "Congresso de Jovens", ["Congresso Distrital", "Encontro de Desbravadores"], ["important", "normal"]}
]

descriptions = [
  "Momento especial de comunhão e crescimento espiritual com a presença de toda a congregação.",
  "Atendimento pastoral individual disponível após o término do programa.",
  "Comissão distrital para alinhamento das atividades do próximo trimestre.",
  "Cerimônia solene de entrega e celebração comunitária.",
  "Treinamento prático voltado para os líderes de departamentos locais."
]

today = Date.utc_today()

for day_offset <- -2..28 do
  date = Date.add(today, day_offset)
  
  # Determine event frequency (more events on Wed, Fri, Sat, Sun)
  # Sunday = 7, Wednesday = 3, Friday = 5, Saturday = 6
  day_of_week = Date.day_of_week(date)
  
  events_to_create =
    cond do
      day_of_week == 6 -> 2 # Saturday always busy
      day_of_week in [3, 7] -> Enum.random([1, 2]) # Wednesday or Sunday
      day_offset == 0 -> 1 # Make sure today has at least 1 event for status card
      true -> Enum.random([0, 1]) # Other days
    end

  if events_to_create > 0 do
    # Time slots for this day: morning (09:00), afternoon (16:00), or evening (19:30)
    slots = [{~T[09:00:00], ~T[11:30:00]}, {~T[16:00:00], ~T[18:00:00]}, {~T[19:30:00], ~T[21:30:00]}]
    selected_slots = Enum.take_random(slots, events_to_create)

    for {start_time, end_time} <- selected_slots do
      # Select random event type config
      {type_key, type_label, titles, priorities} = Enum.random(event_types)
      
      # Select random church
      church = Enum.random(churches)
      
      title = "#{type_label} - #{Enum.random(titles)}"
      priority = Enum.random(priorities)
      desc = Enum.random(descriptions)
      
      # Convert local time (Brasília offset UTC-3) to UTC for DB persistence
      start_at = 
        DateTime.new!(date, start_time, "Etc/UTC")
        |> DateTime.add(3, :hour) # shift UTC-3 to UTC
        
      end_at = 
        DateTime.new!(date, end_time, "Etc/UTC")
        |> DateTime.add(3, :hour)

      Repo.insert!(%Event{
        title: title,
        description: desc,
        start_at: start_at,
        end_at: end_at,
        type: type_key,
        priority: priority,
        status: "scheduled",
        church_id: church.id,
        created_by: pastor.id
      })
    end
  end
end

IO.puts("Seeding complete! Random events successfully generated.")
