defmodule Coeus do
  alias Coeus.Connection

  import Absinthe.Resolution.Helpers, only: [dataloader: 3]

  def resolve_connection(module, query_fn, repo_fn) do
    Connection.from_query(module, query_fn, repo_fn)
  end

  def resolve_dataloader(loader, resource, opts \\ []) do
    opts =
      Keyword.put(opts, :callback, fn result, _parent, args ->
        {:ok, Connection.from_slice(result, args)}
      end)

    dataloader(loader, resource, opts)
  end
end
