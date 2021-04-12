defmodule Coeus.Mutation do
  @moduledoc """
  Middleware to support the macros located in:

  - For Relay Modern:  `Absinthe.Relay.Mutation.Notation.Modern`
  - For Relay Classic: `Absinthe.Relay.Mutation.Notation.Classic`

  Please see those modules for specific instructions.
  """

  @doc false

  # System resolver to extract values from the input and return the
  # client mutation ID (the latter for Relay Classic only) as part of the response.
  def call(%{state: :unresolved} = resolution, []) do
    case resolution.arguments do
      %{input: input} ->
        %{
          resolution
          | arguments: input,
            private: Map.merge(resolution.private, %{__parse_ids_root: :input}),
            middleware: resolution.middleware ++ [__MODULE__]
        }

      _ ->
        resolution
    end
  end

  def call(resolution, []), do: resolution
end
