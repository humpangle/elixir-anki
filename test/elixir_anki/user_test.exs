defmodule ElixirAnki.UserTest do
  use ElixirAnki.DataCase

  alias ElixirAnki.UserApi, as: Api
  alias ElixirAnki.User

  @valid_attrs %{
    email: Faker.Internet.email(),
    password_hash: "some password_hash",
    username: "some username"
  }
  @update_attrs %{
    email: Faker.Internet.email(),
    password_hash: "some updated password_hash",
    username: "some updated username"
  }
  @invalid_attrs %{email: nil, password_hash: nil, username: nil}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Api.create_()

    user
  end

  test "list/0 returns all users" do
    user = user_fixture()
    assert Api.list() == [user]
  end

  test "get!/1 returns the user with given id" do
    user = user_fixture()
    assert Api.get!(user.id) == user
  end

  test "create_/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Api.create_(@valid_attrs)
    assert user.email == @valid_attrs.email
    assert user.password_hash == "some password_hash"
    assert user.username == "some username"
  end

  test "create_/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Api.create_(@invalid_attrs)
  end

  test "update_/2 with valid data updates the user" do
    user = user_fixture()
    assert {:ok, user} = Api.update_(user, @update_attrs)
    assert %User{} = user
    assert user.email == @update_attrs.email
    assert user.password_hash == "some updated password_hash"
    assert user.username == "some updated username"
  end

  test "update_/2 with invalid data returns error changeset" do
    user = user_fixture()
    assert {:error, %Ecto.Changeset{}} = Api.update_(user, @invalid_attrs)
    assert user == Api.get!(user.id)
  end

  test "delete_/1 deletes the user" do
    user = user_fixture()
    assert {:ok, %User{}} = Api.delete_(user)
    assert_raise Ecto.NoResultsError, fn -> Api.get!(user.id) end
  end

  test "change_/1 returns a user changeset" do
    user = user_fixture()
    assert %Ecto.Changeset{} = Api.change_(user)
  end
end
