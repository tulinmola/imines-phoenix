defmodule Imines.Status do
  def init do
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true])
  end

  def set_last_seen(x, y) do
    set("last_seen", {x, y, system_time})
  end

  def last_seen do
    get("last_seen")
  end

  defp set(key, value) do
    :ets.insert(__MODULE__, {key, value})
  end
  defp get(key) do
    case :ets.lookup(__MODULE__, key) do
      [value] -> value |> elem(1)
      _ -> nil
    end
  end

  defp system_time do
    {mega, seconds, ms} = :os.timestamp()
    (mega * 1000000 + seconds) * 1000 + :erlang.round(ms / 1000)
  end
end
