defmodule Imines.TileTest do
  use Imines.ModelCase
  import Imines.Factory

  alias Imines.Tile
  alias Ecto.Changeset

  @invalid_attrs %{}

  test "changeset with valid attributes and default generator" do
    changeset = build_tile()
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Tile.changeset(%Tile{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid name" do
    changeset = Tile.changeset_with_generator(%Tile{}, %{name: "invalid"})
    refute changeset.valid?
  end

  test "changeset with invalid name x coordinate" do
    changeset = Tile.changeset_with_generator(%Tile{}, %{name: "_x0"})
    refute changeset.valid?
  end

  test "changeset with invalid name y coordinate" do
    changeset = Tile.changeset_with_generator(%Tile{}, %{name: "0x_"})
    refute changeset.valid?
  end

  test "changeset with custom generator" do
    changeset = build_water_tile!()
    count = Tile.size * Tile.size
    expected_values = 1..count |> Enum.map(fn(_) -> Tile.water end)
    assert Changeset.get_field(changeset, :values) == expected_values
  end

  test "get or create tile by name" do
    tile = Tile.get_or_create_tile!("42x42")
    assert tile
  end

  test "showing non water does nothing" do
    assert :no_op = create_bombs_tile!() |> Tile.show(0, 0)
  end

  test "showing bomb behind water kills you" do
    assert {:bomb, _changeset} = create_water_with_bombs_tile!() |> Tile.show(0, 0)
  end

  test "showing water with no bombs around inside tile counts 0" do
    assert {:count, 0, _changeset} = create_water_tile!() |> Tile.show(1, 1)
  end

  test "showing water with no bombs around between various tiles counts 0" do
    create_water_tile!("-1x0")
    assert {:count, 0, _changeset} = create_water_tile!("0x0") |> Tile.show(0, 1)
  end
end
