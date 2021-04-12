defmodule Coeus.Connection.Notation do
  @moduledoc """
  Macros used to define Connection-related schema entities

  See `Absinthe.Relay.Connection` for more information.

  If you wish to use this module on its own without `use Absinthe.Relay` you
  need to include
  ```
  @pipeline_modifier Absinthe.Relay.Schema
  ```
  in your root schema module.
  """

  alias Absinthe.Blueprint

  @naming_attrs [:node_type, :non_null, :non_null_edges, :non_null_edge, :connection]

  defmodule Naming do
    @moduledoc false

    defstruct base_identifier: nil,
              node_type_identifier: nil,
              connection_type_identifier: nil,
              edge_type_identifier: nil,
              non_null_edges: false,
              non_null_edge: false,
              attrs: []

    def from_attrs!(attrs) do
      node_type_identifier =
        attrs[:node_type] ||
          raise(
            "Must provide a `:node_type' option (an optional `:connection` option is also supported)"
          )

      base_identifier = attrs[:connection] || node_type_identifier
      non_null_edges = attrs[:non_null_edges] || attrs[:non_null] || false
      non_null_edge = attrs[:non_null_edge] || attrs[:non_null] || false

      %__MODULE__{
        node_type_identifier: node_type_identifier,
        base_identifier: base_identifier,
        connection_type_identifier: ident(base_identifier, :connection),
        edge_type_identifier: ident(base_identifier, :edge),
        non_null_edges: non_null_edges,
        non_null_edge: non_null_edge,
        attrs: [
          node_type: node_type_identifier,
          connection: base_identifier,
          non_null_edges: non_null_edges,
          non_null_edge: non_null_edge
        ]
      }
    end

    defp ident(base, category) do
      :"#{base}_#{category}"
    end
  end

  @doc """
  Define a connection type for a given node type.

  ## Examples

  A basic connection for a node type, `:pet`. This well generate simple
  `:pet_connection` and `:pet_edge` types for you:

  ```
  connection node_type: :pet
  ```

  You can provide a custom name for the connection type (just don't include the
  word "connection"). You must still provide the `:node_type`. You can create as
  many different connections to a node type as you want.

  This example will create a connection type, `:favorite_pets_connection`, and
  an edge type, `:favorite_pets_edge`:

  ```
  connection :favorite_pets, node_type: :pet
  ```

  You can customize the connection object just like any other `object`:

  ```
  connection :favorite_pets, node_type: :pet do
    field :total_age, :float do
      resolve fn
        _, %{source: conn} ->
          sum = conn.edges
          |> Enum.map(fn edge -> edge.node.age)
          |> Enum.sum
          {:ok, sum}
      end
    end
    edge do
      # ...
    end
  end
  ```

  Just remember that if you use the block form of `connection`, you must call
  the `edge` macro within the block to make sure the edge type is generated.
  See the `edge` macro below for more information.
  """
  defmacro connection({:field, _, [identifier, attrs]}, do: block) when is_list(attrs) do
    do_connection_field(identifier, attrs, block)
  end

  defmacro connection(identifier, attrs) do
    naming = Naming.from_attrs!(Keyword.put(attrs, :connection, identifier))
    do_connection_definition(naming, attrs)
  end

  defmacro connection(attrs) do
    naming = Naming.from_attrs!(attrs)
    do_connection_definition(naming, attrs)
  end

  defp do_connection_field(identifier, attrs, block) do
    naming = Naming.from_attrs!(attrs)
    {limit, attrs} = Keyword.pop(attrs, :limit, 50)
    {page, attrs} = Keyword.pop(attrs, :page, 1)

    field_attrs =
      attrs
      |> Keyword.drop(@naming_attrs)
      |> Keyword.put(:type, naming.connection_type_identifier)

    quote do
      field unquote(identifier), unquote(field_attrs) do
        private(
          :coeus,
          {:paginate, {unquote(limit), unquote(page)}},
          {:fill, unquote(__MODULE__)}
        )

        unquote(block)
      end
    end
  end

  defp do_connection_definition(naming, attrs) do
    identifier = naming.connection_type_identifier
    attrs = Keyword.drop(attrs, @naming_attrs)

    quote do
      object unquote(identifier), unquote(attrs) do
        field(:page_info, type: non_null(:page_info))
        field(:entries, type: non_null(list_of(unquote(naming.node_type_identifier))))
      end
    end
  end

  def additional_types(_, _), do: []

  def fillout({:paginate, {limit, page}}, node) do
    Map.update!(node, :arguments, fn arguments ->
      put_uniq(
        [
          build_arg(:limit, :limit, limit),
          build_arg(:page, :page, page)
        ],
        arguments
      )
    end)
  end

  def fillout(_, node) do
    node
  end

  defp put_uniq(new, prior) do
    existing = MapSet.new(prior, & &1.identifier)

    new
    |> Enum.filter(&(!(&1.identifier in existing)))
    |> Enum.concat(prior)
  end

  defp build_arg(id, type, default_value) do
    %Blueprint.Schema.InputValueDefinition{
      name: Atom.to_string(id),
      identifier: id,
      type: type,
      default_value: default_value,
      module: __MODULE__,
      __reference__: Absinthe.Schema.Notation.build_reference(__ENV__)
    }
  end
end
