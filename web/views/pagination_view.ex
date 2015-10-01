defmodule DotaQuantify.PaginationView do
  use DotaQuantify.Web, :view
  require IEx

  def pagination_links(page, opts) do
    [
      first_link(page, opts),
      " ",
      prev_link(page, opts),
      " ",
      next_link(page, opts),
      " ",
      last_link(page, opts)
    ]
  end

  defp first_link(%Scrivener.Page{page_number: 1}, _opts), do: "<<"
  defp first_link(_page, opts) do
    params = Map.delete(opts, "page") |> get_params
    link("<<", to: params)
  end

  defp prev_link(%Scrivener.Page{page_number: 1}, _opts), do: "<Prev"
  defp prev_link(_page, opts) do
    prev_page = String.to_integer(opts["page"]) - 1
    params = get_params(opts, %{"page" => prev_page})
    link("<Prev", to: params)
  end

  defp next_link(%Scrivener.Page{page_number: page_number, total_pages: total_pages}, opts) do
    if page_number == total_pages do
      "Next>"
    else
      next_page = if opts["page"], do: String.to_integer(opts["page"]) + 1, else: 2
      params = get_params(opts, %{"page" => next_page})
      link("Next>", to: params)
    end
  end

  defp last_link(%Scrivener.Page{page_number: page_number, total_pages: total_pages}, opts) do
    if page_number == total_pages do
      ">>"
    else
      params = get_params(opts, %{"page" => total_pages})
      link(">>", to: params)
    end
  end

  # defp get_params(%{}), do: "?"
  defp get_params(opts, overrides \\ %{}) do
    opts
    |> Map.merge(overrides)
    |> Enum.reduce("?", fn {k, v}, s ->
      joiner = if s == "?", do: "", else: "&"
      "#{s}#{joiner}#{k}=#{v}"
    end)
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
