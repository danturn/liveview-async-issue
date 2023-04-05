defmodule TestWeb.PageLiveTest do
  use TestWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "can assert on update from parent syncronously", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p|/|)

    view
    |> element("#parent-form")
    |> render_submit()
  end

  test "cannot assert on update from child syncronously", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p|/|)

    view
    |> element("#child-form")
    |> render_submit()
  end
end
