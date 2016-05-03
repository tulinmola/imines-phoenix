defmodule Imines.Tile do
  use Imines.Web, :model

  @size 8
  @bombs_factor 0.2

  @bomb 9
  @water 10
  @water_with_bomb 11

  def water, do: @water
  def bomb, do: @bomb
  def size, do: @size

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "tiles" do
    field :name
    field :values, {:array, :integer}

    timestamps
  end

  @required_fields ~w(name values)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
    |> validate_values_count
  end

  defp validate_values_count(changeset) do
    validate_values_count(changeset, Enum.count(get_field(changeset, :values, [])))
  end
  defp validate_values_count(changeset, count) when count == @size * @size, do: changeset
  defp validate_values_count(changeset, _) do
    add_error(changeset, :values, "Invalid values length")
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
  defp random_value(rand), do: @water

  def get_value(%Ecto.Changeset{changes: changes}, x, y) do
    get_value(changes, x, y)
  end
  def get_value(model, x, y) do
    index = values_index(x, y)
    value = model.values |> Enum.at(index)
    case value do
      count when value <= 8 -> {:count, count}
      _ when value == @bomb or value == @water_with_bomb -> {:bomb}
      _ -> {:water}
    end
  end

  def set_value(model, x, y, value) do
    index = values_index(x, y)
    updated_values = model.values |> List.replace_at(index, value)
    change(model, %{values: updated_values})
  end

  defp values_index(x, y), do: y * @size + x
end
