defmodule Dotes.MatchControllerTest do
  use DotesWeb.ConnCase

  alias Dotes.Match
  @valid_attrs %{match_id: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, match_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing matches"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, match_path(conn, :new)
    assert html_response(conn, 200) =~ "New match"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, match_path(conn, :create), match: @valid_attrs
    assert redirected_to(conn) == match_path(conn, :index)
    assert Repo.get_by(Match, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, match_path(conn, :create), match: @invalid_attrs
    assert html_response(conn, 200) =~ "New match"
  end

  test "shows chosen resource", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :show, match)
    assert html_response(conn, 200) =~ "Show match"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, match_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :edit, match)
    assert html_response(conn, 200) =~ "Edit match"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @valid_attrs
    assert redirected_to(conn) == match_path(conn, :show, match)
    assert Repo.get_by(Match, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit match"
  end

  test "deletes chosen resource", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = delete conn, match_path(conn, :delete, match)
    assert redirected_to(conn) == match_path(conn, :index)
    refute Repo.get(Match, match.id)
  end
end
