defmodule DotesWeb.RollApiView do
  use Dotes.Web, :view
  
  def render("index.json", %{rolls: rolls, users: users}) do
    %{
      rolls: Enum.map(rolls, &roll_json/1),
      users: Enum.map(users, &user_json/1),
    }
  end

  def roll_json(roll) do
    %{
      inserted_at: roll.inserted_at,
      number: roll.number,
      eligible_user_ids: roll.eligible_user_ids,
      immune_user_ids: roll.immune_user_ids
    }
  end

  def user_json(user) do
    %{
      personaname: user.personaname,
      id: user.id,
    }
  end
end