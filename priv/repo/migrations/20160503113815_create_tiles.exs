defmodule Imines.Repo.Migrations.CreateTiles do
  use Ecto.Migration

  def change do
    # create table(:tiles)
    create unique_index(:tiles, [:name])
    execute touch: "tiles", data: true, index: true
  end
end
