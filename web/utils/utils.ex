defmodule Dotes.Utils do
  require IEx

  def rename_keys(:empty, _keys), do: :empty
  def rename_keys(map, keys) do
    Enum.reduce(keys, map, fn {old, new}, map ->
      result = Map.fetch(map, old)
      case result do
        :error ->
          map
        {:ok, value} ->
          map |> Map.delete(old) |> Map.put(new, value)
      end
    end)
  end

  defmodule Time do
    epoch = {{1970, 1, 1}, {0, 0, 0}}
    @epoch :calendar.datetime_to_gregorian_seconds(epoch)

    def from_timestamp(timestamp) do
      timestamp
      |> +(@epoch)
      |> :calendar.gregorian_seconds_to_datetime
      |> Timex.Date.from
      |> Timex.Date.local
    end

    def to_timestamp(datetime) do
      datetime
      |> :calendar.datetime_to_gregorian_seconds
      |> -(@epoch)
    end
  end

end