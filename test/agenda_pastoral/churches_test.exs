defmodule AgendaPastoral.ChurchesTest do
  use AgendaPastoral.DataCase

  alias AgendaPastoral.Churches
  alias AgendaPastoral.Churches.Church

  import AgendaPastoral.ChurchesFixtures

  @invalid_attrs %{active: nil, city: nil, name: nil, state: nil, district_id: nil}

  describe "churches" do
    test "list_churches/0 returns all churches" do
      church = church_fixture()
      assert Churches.list_churches() == [church]
    end

    test "get_church!/1 returns the church with given id" do
      church = church_fixture()
      assert Churches.get_church!(church.id) == church
    end

    test "create_church/1 with valid data creates a church" do
      valid_attrs = %{active: true, city: "some city", name: "some name", state: "some state"}
      district = AgendaPastoral.DistrictsFixtures.district_fixture()
      valid_attrs = Map.put(valid_attrs, :district_id, district.id)

      assert {:ok, %Church{} = church} = Churches.create_church(valid_attrs)
      assert church.active == true
      assert church.city == "some city"
      assert church.name == "some name"
      assert church.state == "some state"
    end

    test "create_church/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Churches.create_church(@invalid_attrs)
    end

    test "update_church/2 with valid data updates the church" do
      church = church_fixture()

      update_attrs = %{
        active: false,
        city: "some updated city",
        name: "some updated name",
        state: "some updated state"
      }

      assert {:ok, %Church{} = church} = Churches.update_church(church, update_attrs)
      assert church.active == false
      assert church.city == "some updated city"
      assert church.name == "some updated name"
      assert church.state == "some updated state"
    end

    test "update_church/2 with invalid data returns error changeset" do
      church = church_fixture()
      assert {:error, %Ecto.Changeset{}} = Churches.update_church(church, @invalid_attrs)
      assert church == Churches.get_church!(church.id)
    end

    test "delete_church/1 deletes the church" do
      church = church_fixture()
      assert {:ok, %Church{}} = Churches.delete_church(church)
      assert_raise Ecto.NoResultsError, fn -> Churches.get_church!(church.id) end
    end

    test "change_church/1 returns a church changeset" do
      church = church_fixture()
      assert %Ecto.Changeset{} = Churches.change_church(church)
    end
  end
end
