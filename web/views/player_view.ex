defmodule Dotes.PlayerView do
  use Dotes.Web, :view

  def item_img(id, opts \\ []) do
    case Dota.Item.get(id) do
      nil -> nil
      item ->
        tag :img, [{:src, "/images/items/#{item["name"]}_lg.png"} | opts]
    end
  end

  def hero_img(id, size \\ "sb.png") do
    case Dota.Hero.get(id) do
      nil -> nil
      hero ->
        tag :img, src: "/images/heroes/#{hero["name"]}_#{size}"
    end
  end
end
