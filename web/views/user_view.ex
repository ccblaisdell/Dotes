defmodule DotaQuantify.UserView do
  use DotaQuantify.Web, :view

  def dotabuff_user_url(id), do: "http://dotabuff.com/players/#{id}"

  def yasp_user_url(id), do: "http://yasp.co/players/#{id}"
end
