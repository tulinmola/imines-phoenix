defmodule Imines.Factory do
  alias Imines.{Tile, Repo}

  defp water_generator, do: Tile.water
  defp bomb_generator, do: Tile.bomb
  defp water_with_bomb_generator, do: Tile.water_with_bomb

  def build_tile(name \\ "0x0") do
    Tile.changeset_with_generator(%Tile{}, %{name: name})
  end
  def build_water_tile!(name \\ "0x0") do
    Tile.changeset_with_generator(%Tile{}, %{name: name}, &water_generator/0)
  end

  def create_tile!(name \\ "0x0") do
    Tile.changeset_with_generator(%Tile{}, %{name: name})
    |> Repo.insert!()
  end
  def create_water_tile!(name \\ "0x0") do
    Tile.changeset_with_generator(%Tile{}, %{name: name}, &water_generator/0)
    |> Repo.insert!()
  end
  def create_water_with_bombs_tile!(name \\ "0x0") do
    Tile.changeset_with_generator(%Tile{}, %{name: name}, &water_with_bomb_generator/0)
    |> Repo.insert!()
  end
  def create_bombs_tile!(name \\ "0x0") do
    Tile.changeset_with_generator(%Tile{}, %{name: name}, &bomb_generator/0)
    |> Repo.insert!()
  end
end
