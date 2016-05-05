defmodule Imines.TileChannel do
  use Imines.Web, :channel

  alias Imines.{Tile, TileView, Repo}

  def join("tiles:" <> name, _payload, socket) do
    tile = Tile.get_or_create_tile!(name)
    response = %{values: TileView.values(tile)}
    {:ok, response, assign(socket, :name, name)}
  end

  def handle_in("show", %{x: x, y: y}, socket) do
    tile = Repo.get_by(Tile, name: socket.assigns.name)
    payload = case Tile.show(tile, x, y) do
      {:bomb, changeset} ->
        Repo.update!(changeset)
        broadcast socket, "update", %{x: x, y: y, value: Tile.bomb}
        %{status: "bomb"}
      {:count, count, changeset} ->
        Repo.update!(changeset)
        broadcast socket, "update", %{x: x, y: y, value: count}
        %{status: "count", score: count}
      _ ->
        %{status: "none"}
    end
    {:reply, {:ok, payload}, socket}
  end
end
