defmodule Imines.Tile do
  use Imines.Web, :model

  alias Imines.Repo

  @size 8
  @bombs_factor 0.2

  @bomb 9
  @water 10
  @water_with_bomb 11

  @neightbours [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]

  def water, do: @water
  def bomb, do: @bomb
  def water_with_bomb, do: @water_with_bomb
  def size, do: @size

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "tiles" do
    field :name
    field :values, {:array, :integer}

    timestamps
  end

  @required_fields ~w(name values)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
    |> validate_name
    |> validate_values_count
  end

  defp validate_values_count(changeset) do
    validate_values_count(changeset, Enum.count(get_field(changeset, :values, [])))
  end

  defp validate_values_count(changeset, count) when count == @size * @size do
    changeset
  end

  defp validate_values_count(changeset, _) do
    add_error(changeset, :values, "Invalid values length")
  end

  defp validate_name(changeset) do
    name = get_field(changeset, :name)
    validate_name(changeset, name)
  end

  defp validate_name(changeset, name) when is_binary(name) do
    case String.split(name, "x") do
      [xs, ys] ->
        changeset
        |> validate_tile_coordinate(xs)
        |> validate_tile_coordinate(ys)
      _ ->
        add_error(changeset, :name, "Invalid name format")
    end
  end
  defp validate_name(changeset, _) do
    add_error(changeset, :values, "Invalid name type")
  end

  defp validate_tile_coordinate(changeset, value) do
    case Integer.parse(value) do
      :error -> add_error(changeset, :name, "Invalid tile position")
      _ -> changeset
    end
  end

  def changeset_with_generator(model, params \\ :empty, generator \\ &random_value/0) do
    params_with_values = Map.merge(params, %{values: create_values(generator)})
    changeset(model, params_with_values)
  end

  defp create_values(generator) do
    1..@size * @size
    |> Enum.map(fn(_) -> generator.() end)
  end

  defp random_value(), do: random_value(:rand.uniform())

  defp random_value(rand) when rand < @bombs_factor, do: @water_with_bomb

  defp random_value(_rand), do: @water

  def show(model, x, y) do
    value = model |> get_value(x, y)
    case value do
      @water_with_bomb ->
        {:bomb, change_value(model, x, y, @bomb)}
      @water ->
        count = bombs_count(model, x, y)
        {:count, count, change_value(model, x, y, count)}
      _ ->
        :no_op
    end
  end

  def bombs_count(model, x, y) do
    @neightbours
    |> Enum.count(fn({dx, dy}) -> is_bomb?(model, x + dx, y + dy) end)
  end

  def change_value(model, x, y, value) do
    index = values_index(x, y)
    updated_values = model.values |> List.replace_at(index, value)
    change(model, %{values: updated_values})
  end

  defp is_bomb?(model, x, y) when x >= 0 and y >= 0 and x < @size and y < @size do
    value = model |> get_value(x, y)
    value == @water_with_bomb or value == @bomb
  end

  defp is_bomb?(model, x, y) do
    {tx, ty} = tile_coords(model)
    dtx = round(Float.floor(x / @size))
    dty = round(Float.floor(y / @size))
    other = get_or_create_tile!("#{tx + dtx}x#{ty + dty}")
    # TODO: this generates 3 to 5 db fetches depending on witch part of tile
    # boundary we are. It could be reduced to 1 to 3 with a mini cache here or
    # reduced completely using some kind of general memory cache. So this is
    # something to be inquired.
    is_bomb?(other, mod(x), mod(y))
  end

  def get_or_create_tile!(name) do
    tile = Repo.get_by(__MODULE__, name: name)
    unless tile do
      changeset = changeset_with_generator(%__MODULE__{}, %{name: name})
      tile = Repo.insert!(changeset)
    end
    tile
  end

  def get_value(model, x, y) do
    index = values_index(x, y)
    model.values |> Enum.at(index)
  end

  defp mod(x, y \\ @size), do: rem(rem(x, y) + y, y)

  defp tile_coords(model) do
    [xs, ys] = String.split(model.name, "x")
    {elem(Integer.parse(xs), 0), elem(Integer.parse(ys), 0)}
  end

  defp values_index(x, y) do
    x = mod(x)
    y = mod(y)
    y * @size + x
  end
end
