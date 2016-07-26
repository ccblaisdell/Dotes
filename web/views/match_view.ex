defmodule Dotes.MatchView do
  use Dotes.Web, :view
  alias Dotes.Player
  alias Dotes.PlayerView
  
  @short_time_format_string "{WDshort} {h12}:{m}{am}"
  @long_time_format_string "{M}-{D}-{YYYY}, {h12}:{m}{am}"

  def format_time(time) when is_integer(time), do:
    format_time( Dotes.Utils.Time.from_timestamp(time) )

  def format_time(time) do
    case Timex.format(time, @short_time_format_string) do
      {:ok, str} -> str
      {:error, _} -> "bad time"
    end
  end

  def format_time_long(time) when is_integer(time), do:
    format_time_long( Dotes.Utils.Time.from_timestamp(time) )

  def format_time_long(time) do
    case Timex.format(time, @long_time_format_string) do
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
  
  def list_match_table(match, players, team, conn) do
    content_tag :table, [ match_table_head(team), match_table_players(match, players, conn) ], class: "match-table"
  end
  
  def match_table(match, conn) do
    content_tag :table, [ match_table_head("Radiant"), match_table_players(match, Player.radiant_team(match.players), conn),
                          match_table_head("Dire"), match_table_players(match, Player.dire_team(match.players), conn)], class: "match-table"
  end
  
  def match_table_head(team) do
    cols = [team, "lvl", "kda", "g", "gs", "lh", "d", "gpm", "xpm", "hd", "hh", "td", "items", ""]
    content_tag :thead, 
      content_tag(:tr, Enum.map(cols, fn col -> content_tag(:th, col) end))
  end
  
  # def match_table_head("Dire" = team) do
  #   content_tag :thead, 
  #     content_tag(:tr, content_tag(:th, team))
  # end
  
  def match_table_players(match, players, conn) do
    content_tag :tbody, Enum.map(players, fn player -> render(PlayerView, "player.html", player: player, match: match, conn: conn) end)
  end

end
