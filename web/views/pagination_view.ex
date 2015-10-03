defmodule DotaQuantify.PaginationView do
  use DotaQuantify.Web, :view
  require IEx

  def pagination_links(conn, page) do
    [
      first_link(conn, page),
      " ",
      prev_link(conn, page),
      " ",
      next_link(conn, page),
      " ",
      last_link(conn, page)
    ]
  end

  defp first_link(_conn, %Scrivener.Page{page_number: 1}), do: "<<"
  defp first_link(conn, _page) do
    params = conn.query_string
    |> parse_query_string
    |> Map.delete("page")
    |> map_to_query_string
    link("<<", to: conn.request_path <> params)
  end

  defp prev_link(_conn, %Scrivener.Page{page_number: 1}), do: "<Prev"
  defp prev_link(conn, %Scrivener.Page{page_number: 2}) do
    params = conn.query_string
    |> parse_query_string
    |> Map.delete("page")
    |> map_to_query_string
    link("<Prev", to: conn.request_path <> params)
  end
  defp prev_link(conn, _page) do
    params = conn.query_string
    |> parse_query_string
    |> Map.update("page", "1", &( String.to_integer(&1) - 1 ))
    |> map_to_query_string
    link("<Prev", to: params)
  end

  defp next_link(conn, %Scrivener.Page{page_number: page_number, total_pages: total_pages})
       when page_number == total_pages, do: "Next>"
  defp next_link(conn, %Scrivener.Page{page_number: page_number, total_pages: total_pages}) do
    params = conn.query_string
    |> parse_query_string
    |> Map.update("page", "2", &( String.to_integer(&1) + 1 ))
    |> map_to_query_string
    link("Next>", to: params)
  end

  defp last_link(conn, %Scrivener.Page{page_number: page_number, total_pages: total_pages}) do
    if page_number == total_pages do
      ">>"
    else
      params = conn.query_string
      |> parse_query_string
      |> Map.put("page", total_pages)
      |> map_to_query_string
      link(">>", to: params)
    end
  end

  defp map_to_query_string(params) when params == %{}, do: ""
  defp map_to_query_string(params, overrides \\ %{}) do
    params
    |> Map.merge(overrides)
    |> Enum.reduce("?", fn {k, v}, s ->
      joiner = if s == "?", do: "", else: "&"
      "#{s}#{joiner}#{k}=#{v}"
    end)
  end

  defp parse_query_string(""), do: %{}
  defp parse_query_string(query_string) do
    query_string
    |> String.split("&")
    |> Enum.map(&String.split(&1, "="))
    |> Enum.map(fn [k, v] -> {k, v} end)
    |> Enum.into(%{})
  end

  def pagination_window(page) do
    ["showing ", page_start(page), " - ", page_end(page), " of ", total_entries(page)]
  end

  defp page_start(page) do
    (page.page_number * page.page_size) - page.page_size + 1 |> Integer.to_string
  end

  defp page_end(page) do
    Enum.min([page.page_number * page.page_size, page.total_entries]) |> Integer.to_string
  end

  defp total_entries(page) do
    page.total_entries |> Integer.to_string
  end
end
