defmodule Imines.PageController do
  use Imines.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
