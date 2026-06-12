defmodule AgendaPastoral.AlterationsTest do
  use AgendaPastoral.DataCase

  alias AgendaPastoral.Alterations
  alias AgendaPastoral.Alterations.Alteration

  import AgendaPastoral.AlterationsFixtures

  @invalid_attrs %{description: nil, event_id: nil, user_id: nil}

  describe "alterations" do
    test "list_alterations/0 returns all alterations" do
      alteration = alteration_fixture()
      assert Enum.map(Alterations.list_alterations(), &(&1.id)) == [alteration.id]
    end

    test "get_alteration!/1 returns the alteration with given id" do
      alteration = alteration_fixture()
      assert Alterations.get_alteration!(alteration.id).id == alteration.id
    end

    test "create_alteration/1 with valid data creates an alteration" do
      event = AgendaPastoral.EventsFixtures.event_fixture()
      user = AgendaPastoral.AccountsFixtures.user_fixture()
      valid_attrs = %{description: "some description", event_id: event.id, user_id: user.id}

      assert {:ok, %Alteration{} = alteration} = Alterations.create_alteration(valid_attrs)
      assert alteration.description == "some description"
    end

    test "create_alteration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Alterations.create_alteration(@invalid_attrs)
    end

    test "update_alteration/2 with valid data updates the alteration" do
      alteration = alteration_fixture()
      update_attrs = %{description: "some updated description"}

      assert {:ok, %Alteration{} = alteration} = Alterations.update_alteration(alteration, update_attrs)
      assert alteration.description == "some updated description"
    end

    test "update_alteration/2 with invalid data returns error changeset" do
      alteration = alteration_fixture()
      assert {:error, %Ecto.Changeset{}} = Alterations.update_alteration(alteration, @invalid_attrs)
      assert Alterations.get_alteration!(alteration.id).id == alteration.id
    end

    test "delete_alteration/1 deletes the alteration" do
      alteration = alteration_fixture()
      assert {:ok, %Alteration{}} = Alterations.delete_alteration(alteration)
      assert_raise Ecto.NoResultsError, fn -> Alterations.get_alteration!(alteration.id) end
    end

    test "change_alteration/1 returns an alteration changeset" do
      alteration = alteration_fixture()
      assert %Ecto.Changeset{} = Alterations.change_alteration(alteration)
    end
  end
end
