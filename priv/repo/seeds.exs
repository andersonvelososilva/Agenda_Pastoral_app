# Script for populating the database.
alias AgendaPastoral.Repo
alias AgendaPastoral.Accounts.User
alias AgendaPastoral.Districts.District
alias AgendaPastoral.Churches.Church

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

    _church ->
      nil
  end
end

IO.puts("Seeding complete!")
