defmodule Imines.TileChannel do
  use Imines.Web, :channel

  alias Imines.{Tile, TileView, Repo, Status}

  def join("tiles:" <> name, _payload, socket) do
    tile = Tile.get_or_create_tile!(name)
    response = %{values: TileView.values(tile)}
    {:ok, response, assign(socket, :name, name)}
  end

  def handle_in("show", %{"x" => x, "y" => y}, socket) do
    tile = Repo.get_by(Tile, name: socket.assigns.name)
    payload = case Tile.show(tile, x, y) do
      {:bomb, changeset} ->
        value = TileView.value_view(Tile.bomb)
        update_tile_and_broadcast(socket, changeset, %{x: x, y: y, value: value})
        %{status: "bomb"}
      {:count, count, changeset} ->
        update_tile_and_broadcast(socket, changeset, %{x: x, y: y, value: count})
        %{status: "count", value: count, score: count}
      _ ->
        %{status: "none"}
    end
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("mark", %{"x" => x, "y" => y}, socket) do
    tile = Repo.get_by(Tile, name: socket.assigns.name)
    payload = case Tile.show(tile, x, y) do
      {:bomb, changeset} ->
        value = TileView.value_view(Tile.flag)
        update_tile_and_broadcast(socket, changeset, %{x: x, y: y, value: value})
        %{status: "ok", score: 20}
      {:count, count, changeset} ->
        update_tile_and_broadcast(socket, changeset, %{x: x, y: y, value: count})
        %{status: "fail"}
      _ ->
        %{status: "none"}
    end
    {:reply, {:ok, payload}, socket}
  end

  defp update_tile_and_broadcast(socket, changeset, payload) do
    Repo.update!(changeset)
    set_last_seen(changeset, payload)
    broadcast(socket, "update", payload)
  end
  defp set_last_seen(changeset, %{x: rx, y: ry}) do
    [tx, ty] = changeset
      |> Ecto.Changeset.get_field(:name)
      |> String.split("x")
      |> Enum.map(&(elem(Integer.parse(&1), 0)))
    x = tx * Tile.size + rx
    y = ty * Tile.size + ry
    Status.set_last_seen(x, y)
  end
end
