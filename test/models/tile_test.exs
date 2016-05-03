defmodule Imines.TileTest do
  use Imines.ModelCase

  alias Imines.Tile
  alias Ecto.Changeset

  @valid_attrs %{name: "test"}
  @invalid_attrs %{}

  defp water_generator, do: Tile.water
  defp bomb_generator, do: Tile.bomb

  def create_with_water! do
    Tile.changeset_with_generator(%Tile{}, @valid_attrs, &water_generator/0)
    |> Imines.Repo.insert!()
  end
  def create_with_bombs! do
    Tile.changeset_with_generator(%Tile{}, @valid_attrs, &bomb_generator/0)
    |> Imines.Repo.insert!()
  end

  test "changeset with valid attributes but no values given" do
    changeset = Tile.changeset(%Tile{}, @valid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Tile.changeset(%Tile{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with generator" do
    changeset = Tile.changeset_with_generator(%Tile{}, @valid_attrs, &water_generator/0)
    count = Tile.size * Tile.size
    expected_values = 1..count |> Enum.map(fn(_) -> Tile.water end)
    assert Changeset.get_field(changeset, :values) == expected_values
  end

  test "changeset with default generator" do
    changeset = Tile.changeset_with_generator(%Tile{}, @valid_attrs)
    assert changeset.valid?
  end

  test "set/get value" do
    tile = create_with_water!
    changeset = tile |> Tile.set_value(1, 2, 5)
    assert Tile.get_value(changeset, 1, 2) == {:count, 5}
  end

  test "is bomb?" do
    tile = create_with_bombs!
    assert Tile.get_value(tile, 0, 0) == {:bomb}
  end

end
