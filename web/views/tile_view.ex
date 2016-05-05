defmodule Imines.TileView do
  use Imines.Web, :view

  alias Imines.Tile

  @water Tile.water
  @water_with_bomb Tile.water_with_bomb

  def values(tile) do
    tile.values
    |> Enum.map(&value_view/1)
  end

  defp value_view(value) when value == @water_with_bomb, do: @water
  defp value_view(value), do: value
end
