defmodule Dotes.MatchView do
  use Dotes.Web, :view
  @short_time_format_string "{WDshort} {h12}:{m}{am}"
  @long_time_format_string "{M}-{D}-{YYYY}, {h12}:{m}{am}"

  def format_time(time) when is_integer(time), do:
    format_time( Dotes.Utils.Time.from_timestamp(time) )

  def format_time(time) do
    case Timex.DateFormat.format(time, @short_time_format_string) do
      {:ok, str} -> str
      {:error, _} -> "bad time"
    end
  end

  def format_time_long(time) when is_integer(time), do:
    format_time_long( Dotes.Utils.Time.from_timestamp(time) )

  def format_time_long(time) do
    case Timex.DateFormat.format(time, @long_time_format_string) do
      {:ok, str} -> str
      {:error, _} -> "bad time"
    end
  end

  def minutes(time) do
    mins = div(time, 60) |> Integer.to_string
    secs = rem(time, 60) |> Integer.to_string |> String.rjust(2, ?0)
    mins <> ":" <> secs
  end

  def won?(match) do
    case match.players 
        |> Enum.find(fn p -> p.user_id end)
        |> Dotes.Player.won?(match) do
      true ->  content_tag :span, "WON",  style: "color: green;"
      false -> content_tag :span, "LOST", style: "color: red;"
    end
  end

  def dotabuff_match_url(match_id), do: "http://dotabuff.com/matches/#{match_id}"

  def yasp_match_url(match_id), do: "http://yasp.co/matches/#{match_id}"

end
