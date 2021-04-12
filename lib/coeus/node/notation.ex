defmodule Coeus.Node.Notation do
  @moduledoc """
  Macros used to define Node-related schema entities

  See `Absinthe.Relay.Node` for examples of use.

  If you wish to use this module on its own without `use Absinthe.Relay` you
  need to include
  ```
  @pipeline_modifier Absinthe.Relay.Schema
  ```
  in your root schema module.
  """

  @doc """
  Define a node interface, field, or object type for a schema.

  See the `Absinthe.Relay.Node` module documentation for examples.
  """

  defmacro node({:object, meta, [identifier, attrs]}, do: block) when is_list(attrs) do
    do_object(meta, identifier, attrs, block)
  end

  defmacro node({:object, meta, [identifier]}, do: block) do
    do_object(meta, identifier, [], block)
  end

  defp do_object(meta, identifier, attrs, block) do
    {id_fetcher, attrs} = Keyword.pop(attrs, :id_fetcher)
    {id_type, attrs} = Keyword.pop(attrs, :id_type, :id)

    block = [
      quote do
        private(:coeus, :node, {:fill, unquote(__MODULE__)})
        private(:coeus, :id_fetcher, unquote(id_fetcher))
      end,
      object_body(id_fetcher, id_type),
      block
    ]

    {:object, meta, [identifier, attrs] ++ [[do: block]]}
  end

  def additional_types(_, _), do: []

  def fillout(_, node) do
    node
  end

  # Automatically add:
  # - An id field that resolves to the generated global ID
  #   for an object of this type
  # - A declaration that this implements the node interface
  defp object_body(_id_fetcher, id_type) do
    quote do
      @desc "The ID of an object"
      field :id, non_null(unquote(id_type))
    end
  end
end
