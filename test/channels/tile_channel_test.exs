defmodule Imines.TileChannelTest do
  use Imines.ChannelCase
  import Imines.Factory

  alias Imines.{Tile, Repo, TileView}

  @bomb Tile.bomb

  setup do
    {:ok, socket} = connect(Imines.UserSocket, %{some_assigns: 1})
    {:ok, socket: socket}
  end

  test "join replies with tile values", %{socket: socket} do
    tile = create_tile!()
    values = TileView.values(tile)
    {:ok, reply, _socket} = subscribe_and_join(socket, "tiles:#{tile.name}", %{})
    assert values == reply.values
  end

  test "showing water gives you score of 0, broadcasts change and updates tile",
       %{socket: socket} do
    tile = create_water_tile!()
    {:ok, _reply, socket} = subscribe_and_join(socket, "tiles:#{tile.name}", %{})
    ref = push(socket, "show", %{"x" => 4, "y" => 4})
    assert_reply ref, :ok, %{score: 0}
    assert_broadcast "update", %{x: 4, y: 4, value: 0}
    value = Repo.get!(Tile, tile.id) |> Tile.get_value(4, 4)
    assert 0 == value
  end

  test "showing bomb kills you, broadcasts change and updates tile",
       %{socket: socket} do
    tile = create_water_with_bombs_tile!()
    {:ok, _reply, socket} = subscribe_and_join(socket, "tiles:#{tile.name}", %{})
    ref = push(socket, "show", %{"x" => 4, "y" => 4})
    assert_reply ref, :ok, %{status: "bomb"}
    assert_broadcast "update", %{x: 4, y: 4, value: @bomb}
    value = Repo.get!(Tile, tile.id) |> Tile.get_value(4, 4)
    assert @bomb == value
  end

  test "showing already shown makes nothing", %{socket: socket} do
    tile = create_bombs_tile!()
    {:ok, _reply, socket} = subscribe_and_join(socket, "tiles:#{tile.name}", %{})
    ref = push(socket, "show", %{"x" => 4, "y" => 4})
    assert_reply ref, :ok, %{status: "none"}
  end
end
