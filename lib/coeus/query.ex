defmodule Coeus.Query do
  @callback filter(query :: Ecto.Queryable.t(), filters :: map()) :: Ecto.Queryable.t()
  @callback sort(query :: Ecto.Queryable.t(), field :: atom(), dir :: :asc | :desc) ::
              Ecto.Queryable.t()

  @optional_callbacks filter: 2, sort: 3

  defmacro __using__(_opts) do
    quote do
      @behaviour Coeus.Query

      alias Coeus.Query

      import Ecto.Query

      def filter(query, filters) do
        Enum.reduce(filters, query, fn {field, value}, query ->
          Query.filter(query, field, value)
        end)
      end

      def sort(query, field, dir) do
        Query.sort(query, field, dir)
      end

      defoverridable filter: 2, sort: 3
    end
  end

  import Ecto.Query

  def run(module, query, args) do
    args = parse_args(args)

    query
    |> module.filter(args.filter)
    |> maybe_sort(module, args.sort)
    |> tiebreak_sort(args.sort[:dir] || :asc)
    |> maybe_paginate(args)
  end

  defp parse_args(args) do
    args
    |> Map.put_new(:filter, %{})
    |> Map.put_new(:sort, nil)
  end

  def default_params(args \\ %{}, context) do
    Map.put_new(args, :current_user, context[:current_user])
  end

  def filter(query, field, value) do
    where(query, [q], field(q, ^field) == ^value)
  end

  def sort(query, field, dir) do
    order_by(query, [{^dir, ^field}])
  end

  defp maybe_sort(query, _module, nil), do: query
  defp maybe_sort(query, module, %{by: field, dir: dir}), do: module.sort(query, field, dir)

  defp tiebreak_sort(query, dir) do
    order_by(query, [{^dir, :id}])
  end

  defp maybe_paginate(query, %{limit: page_size, page: page_number}) do
    offset = page_size * (page_number - 1)

    query
    |> select_merge([x], %{x | row_count: over(count())})
    |> offset(^offset)
    |> limit(^page_size)
  end

  defp maybe_paginate(query, _args), do: query
end
