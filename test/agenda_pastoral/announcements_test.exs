defmodule AgendaPastoral.AnnouncementsTest do
  use AgendaPastoral.DataCase

  alias AgendaPastoral.Announcements
  alias AgendaPastoral.Announcements.Announcement

  import AgendaPastoral.AnnouncementsFixtures

  @invalid_attrs %{content: nil, title: nil, published_by: nil}

  describe "announcements" do
    test "list_announcements/0 returns all announcements" do
      announcement = announcement_fixture()
      assert Enum.map(Announcements.list_announcements(), &(&1.id)) == [announcement.id]
    end

    test "get_announcement!/1 returns the announcement with given id" do
      announcement = announcement_fixture()
      assert Announcements.get_announcement!(announcement.id).id == announcement.id
    end

    test "create_announcement/1 with valid data creates an announcement" do
      user = AgendaPastoral.AccountsFixtures.user_fixture()
      valid_attrs = %{content: "some content", title: "some title", published_by: user.id}

      assert {:ok, %Announcement{} = announcement} = Announcements.create_announcement(valid_attrs)
      assert announcement.content == "some content"
      assert announcement.title == "some title"
    end

    test "create_announcement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Announcements.create_announcement(@invalid_attrs)
    end

    test "update_announcement/2 with valid data updates the announcement" do
      announcement = announcement_fixture()
      update_attrs = %{content: "some updated content", title: "some updated title"}

      assert {:ok, %Announcement{} = announcement} = Announcements.update_announcement(announcement, update_attrs)
      assert announcement.content == "some updated content"
      assert announcement.title == "some updated title"
    end

    test "update_announcement/2 with invalid data returns error changeset" do
      announcement = announcement_fixture()
      assert {:error, %Ecto.Changeset{}} = Announcements.update_announcement(announcement, @invalid_attrs)
      assert Announcements.get_announcement!(announcement.id).id == announcement.id
    end

    test "delete_announcement/1 deletes the announcement" do
      announcement = announcement_fixture()
      assert {:ok, %Announcement{}} = Announcements.delete_announcement(announcement)
      assert_raise Ecto.NoResultsError, fn -> Announcements.get_announcement!(announcement.id) end
    end

    test "change_announcement/1 returns a announcement changeset" do
      announcement = announcement_fixture()
      assert %Ecto.Changeset{} = Announcements.change_announcement(announcement)
    end
  end
end
