defmodule Dotes.RollControllerTest do
  use DotesWeb.ConnCase

  alias Dotes.Roll
  @valid_attrs %{number: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, roll_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing rolls"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, roll_path(conn, :new)
    assert html_response(conn, 200) =~ "New roll"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, roll_path(conn, :create), roll: @valid_attrs
    assert redirected_to(conn) == roll_path(conn, :index)
    assert Repo.get_by(Roll, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, roll_path(conn, :create), roll: @invalid_attrs
    assert html_response(conn, 200) =~ "New roll"
  end

  test "shows chosen resource", %{conn: conn} do
    roll = Repo.insert! %Roll{}
    conn = get conn, roll_path(conn, :show, roll)
    assert html_response(conn, 200) =~ "Show roll"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, roll_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    roll = Repo.insert! %Roll{}
    conn = get conn, roll_path(conn, :edit, roll)
    assert html_response(conn, 200) =~ "Edit roll"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    roll = Repo.insert! %Roll{}
    conn = put conn, roll_path(conn, :update, roll), roll: @valid_attrs
    assert redirected_to(conn) == roll_path(conn, :show, roll)
    assert Repo.get_by(Roll, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    roll = Repo.insert! %Roll{}
    conn = put conn, roll_path(conn, :update, roll), roll: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit roll"
  end

  test "deletes chosen resource", %{conn: conn} do
    roll = Repo.insert! %Roll{}
    conn = delete conn, roll_path(conn, :delete, roll)
    assert redirected_to(conn) == roll_path(conn, :index)
    refute Repo.get(Roll, roll.id)
  end
end
