defmodule Imines.TileView do
  use Imines.Web, :view

  alias Imines.Tile

  @water Tile.water
  @water_with_bomb Tile.water_with_bomb
  @flag Tile.flag
  @flag_view 11

  def values(tile) do
    tile.values
    |> Enum.map(&value_view/1)
  end

  def value_view(value) when value == @water_with_bomb, do: @water
  def value_view(value) when value == @flag, do: @flag_view
  def value_view(value), do: value
end
