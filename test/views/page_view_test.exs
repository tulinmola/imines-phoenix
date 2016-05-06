defmodule Imines.PageViewTest do
  use Imines.ConnCase, async: true
  import Phoenix.View

  alias Imines.PageView

  test "renders index.html", %{conn: conn} do
    content = render_to_string(PageView, "index.html", conn: conn)
    assert 1 == Enum.count(Floki.find(content, ".axes"))
    assert 1 == Enum.count(Floki.find(content, ".axes .arena"))
  end
end
