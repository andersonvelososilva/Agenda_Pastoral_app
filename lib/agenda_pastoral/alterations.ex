defmodule AgendaPastoral.Alterations do
  @moduledoc """
  The Alterations context.
  """

  import Ecto.Query, warn: false
  alias AgendaPastoral.Repo
  alias AgendaPastoral.Alterations.Alteration

  @doc """
  Returns the list of alterations.
  """
  def list_alterations do
    Repo.all(
      from a in Alteration,
        preload: [:user, event: :church],
        order_by: [desc: a.inserted_at]
    )
  end

  @doc """
  Returns the list of recent alterations.
  """
  def list_recent_alterations(limit \\ 5) do
    Repo.all(
      from a in Alteration,
        preload: [:user, event: :church],
        order_by: [desc: a.inserted_at],
        limit: ^limit
    )
  end

  @doc """
  Gets a single alteration.
  """
  def get_alteration!(id), do: Repo.get!(Alteration, id) |> Repo.preload([:user, :event])

  @doc """
  Creates an alteration.
  """
  def create_alteration(attrs \\ %{}) do
    %Alteration{}
    |> Alteration.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:alteration_created)
  end

  @doc """
  Updates an alteration.
  """
  def update_alteration(%Alteration{} = alteration, attrs) do
    alteration
    |> Alteration.changeset(attrs)
    |> Repo.update()
    |> broadcast(:alteration_updated)
  end

  @doc """
  Deletes an alteration.
  """
  def delete_alteration(%Alteration{} = alteration) do
    Repo.delete(alteration)
    |> broadcast(:alteration_deleted)
  end

  defp broadcast({:ok, alteration} = result, event_name) do
    Phoenix.PubSub.broadcast(AgendaPastoral.PubSub, "alterations", {event_name, alteration})
    result
  end

  defp broadcast({:error, _} = result, _event_name), do: result

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking alteration changes.
  """
  def change_alteration(%Alteration{} = alteration, attrs \\ %{}) do
    Alteration.changeset(alteration, attrs)
  end
end
