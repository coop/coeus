defmodule Coeus.Schema.Notation do
  defmacro __using__(_opts) do
    quote do
      import Coeus.Node.Notation, only: :macros
      import Coeus.Connection.Notation, only: :macros
      import Coeus.Mutation.Notation, only: :macros
    end
  end

  @doc false
  def input(style, identifier, block) do
    quote do
      # We need to go up 2 levels so we can create the input object
      Absinthe.Schema.Notation.stash()
      Absinthe.Schema.Notation.stash()

      input_object unquote(identifier) do
        private(:coeus, :input, {:fill, unquote(style)})
        unquote(block)
      end

      # Back down to finish the field
      Absinthe.Schema.Notation.pop()
      Absinthe.Schema.Notation.pop()
    end
  end

  @doc false
  def output(style, identifier, block) do
    quote do
      Absinthe.Schema.Notation.stash()
      Absinthe.Schema.Notation.stash()

      object unquote(identifier) do
        private(:coeus, :payload, {:fill, unquote(style)})
        unquote(block)
      end

      Absinthe.Schema.Notation.pop()
      Absinthe.Schema.Notation.pop()
    end
  end

  @doc false
  def payload(meta, [field_ident | rest], block) do
    block = rewrite_input_output(field_ident, block)

    {:field, meta, [field_ident, ident(field_ident, :payload) | rest] ++ [[do: block]]}
  end

  defp rewrite_input_output(field_ident, block) do
    Macro.prewalk(block, fn
      {:input, meta, [[do: block]]} ->
        {:input, meta, [ident(field_ident, :input), [do: block]]}

      {:output, meta, [[do: block]]} ->
        {:output, meta, [ident(field_ident, :payload), [do: block]]}

      node ->
        node
    end)
  end

  @doc false
  def ident(base_identifier, category) do
    :"#{base_identifier}_#{category}"
  end
end
