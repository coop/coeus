defmodule Coeus.Connection.Types do
  use Absinthe.Schema.Notation

  object :page_info do
    field :has_previous_page, non_null(:boolean)
    field :has_next_page, non_null(:boolean)
    field :total_pages, non_null(:integer)
    field :total_entries, non_null(:integer)
    field :page, non_null(:page)
    field :limit, non_null(:limit)
  end

  scalar :limit do
    serialize(&Absinthe.Type.BuiltIns.Scalars.serialize_integer/1)

    parse(fn
      %Absinthe.Blueprint.Input.Integer{value: value} when value < 1 -> :error
      %Absinthe.Blueprint.Input.Integer{value: value} -> {:ok, value}
      _other -> :error
    end)
  end

  scalar :page do
    serialize(&Absinthe.Type.BuiltIns.Scalars.serialize_integer/1)

    parse(fn
      %Absinthe.Blueprint.Input.Integer{value: value} when value < 1 -> :error
      %Absinthe.Blueprint.Input.Integer{value: value} -> {:ok, value}
      _other -> :error
    end)
  end
end
