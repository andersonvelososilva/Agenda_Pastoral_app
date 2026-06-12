defmodule AgendaPastoral.Repo do
  use Ecto.Repo,
    otp_app: :agenda_pastoral,
    adapter: Application.compile_env(:agenda_pastoral, :sql_adapter)
end
