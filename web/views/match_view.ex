defmodule Dotes.MatchView do
  use Dotes.Web, :view
  @format_string "{WDshort} {h12}:{m}{am}"

  def format_time(time) when is_integer(time) do
    case Dotes.Utils.Time.from_timestamp(time) |> Timex.DateFormat.format(@format_string) do
      {:ok, str} -> str
      {:error, _} -> "bad time"
    end
  end

  def format_time(time) do
    case Timex.DateFormat.format(time, @format_string) do
      {:ok, str} -> str
      {:error, _} -> "bad time"
    end
  end

  def won?(match) do
    case match.players 
        |> Enum.find(fn p -> p.user_id end)
        |> Dotes.Player.won?(match) do
      true -> "WON"
      false -> "LOST"
    end
  end
end
