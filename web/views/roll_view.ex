defmodule Dotes.RollView do
  use Dotes.Web, :view
  alias Dotes.UserCache
  
  def roller(users, last_roll \\ nil) do
    content_tag :table, style: "text-align: center;" do
      [
        content_tag(:thead,
          content_tag(:tr, [
            content_tag(:th, "Absent", style: "padding: 0 8px; font-weight: normal; opacity: 0.5;"),
            content_tag(:th, "Immune", style: "padding: 0 8px; font-weight: normal;"),
            content_tag(:th, "Eligible", style: "padding: 0 8px; "),
            content_tag(:th, nil) ]))
      ] ++ Enum.map users, fn (user) ->
        content_tag :tr do
          [
            content_tag(:td, roll_radio(user, "absent", is_checked?(user.id, "absent", last_roll))),
            content_tag(:td, roll_radio(user, "immune", is_checked?(user.id, "immune", last_roll))),
            content_tag(:td, roll_radio(user, "eligible", is_checked?(user.id, "eligible", last_roll))),
            content_tag(:td, [content_tag(:img, nil, src: user.avatar), " ", user.personaname], style: "text-align: left;"),
          ]
        end
      end 
    end
  end
  
  def roll_radio(user, value, checked) do
    content_tag :label, style: "display: block; " do
      content_tag :input, nil,
        type: "radio",
        name: "roll[eligibility][#{user.id}]",
        value: value,
        checked: checked
    end
  end
  
  defp is_checked?(_id, "absent", nil), do: true
  defp is_checked?(_id, _value, nil), do: false
  defp is_checked?(id, "eligible", last_roll) do
    was_eligible_for_last_roll = Enum.member?(last_roll.eligible_user_ids, id)
    was_rolled_last = Dotes.Roll.get_user_id(last_roll) == id
    was_eligible_for_last_roll && !was_rolled_last
  end
  defp is_checked?(id, "immune", last_roll) do
    was_immune_last_roll = Enum.member?(last_roll.immune_user_ids, id)
    was_rolled_last = Dotes.Roll.get_user_id(last_roll) == id
    was_immune_last_roll || was_rolled_last
  end
  defp is_checked?(id, "absent", last_roll) do
    was_absent_last_roll = !Enum.member?(last_roll.eligible_user_ids ++ last_roll.immune_user_ids, id)
    was_absent_last_roll
  end
  defp is_checked?(_id, _value, _last_roll), do: false
  
  def roll_list(user_ids) do
    Enum.map user_ids, fn id ->
      content_tag(:img, nil, src: (UserCache.get(id) |> elem(1)).avatar)
    end
  end
  
  def rolled_user(roll) do
    {:ok, user} = Enum.at(roll.eligible_user_ids, roll.number-1) |> UserCache.get
    [
      content_tag(:img, nil, src: user.avatar),
      " ",
      user.personaname
    ]
  end
  
  def roll_absent(present_user_ids) do
    require Logger
    all_users_ids = UserCache.all
    |> elem(1)
    |> Map.values
    |> Enum.map(fn user -> user.id end)
    
    content_tag :div, roll_list(all_users_ids -- present_user_ids),
      style: "opacity: 0.5;"
  end
  
end
