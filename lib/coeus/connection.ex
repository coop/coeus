defmodule Coeus.Connection do
  def from_query(module, query_fn, repo_fn) do
    fn args, resolution ->
      args = Coeus.Query.default_params(args, resolution.context)
      query = Coeus.Query.run(module, query_fn.(args), args)
      results = from_slice(repo_fn.(query), args)

      {:ok, results}
    end
  end

  def from_list(entries, args) do
    {:ok, from_slice(entries, args)}
  end

  def from_slice(entries, %{page: page, limit: page_size}) do
    total_entries = total_entries(entries)
    total_pages = total_pages(total_entries, page_size)

    page_info = %{
      has_previous_page: prev_page?(page, total_pages),
      has_next_page: next_page?(page, total_pages),
      total_pages: total_pages,
      total_entries: total_entries,
      page: page,
      limit: page_size
    }

    %{entries: entries, page_info: page_info}
  end

  defp prev_page?(x, _y), do: x > 1

  defp next_page?(x, y), do: x < y && x != y

  defp total_entries([]), do: 0
  defp total_entries([%{row_count: n} | _]), do: n

  defp total_pages(0, _), do: 1
  defp total_pages(n, page_size), do: n |> Kernel./(page_size) |> Float.ceil() |> round()
end
