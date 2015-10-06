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

end