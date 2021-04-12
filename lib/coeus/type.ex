defmodule Coeus.Type do
  defmacro __using__(_) do
    quote do
      use Absinthe.Schema.Notation
      use Coeus.Schema.Notation

      import Coeus.Type, only: :macros
      import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 2, dataloader: 3]
    end
  end

  defmacro ecto_enum(name, schema, field) do
    values = Ecto.Enum.values(Macro.expand(schema, __CALLER__), field)

    quote do
      enum(unquote(name), values: unquote(values))
    end
  end
end
