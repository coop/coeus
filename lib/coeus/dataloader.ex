defmodule Coeus.Dataloader do
  def add_ecto_source(loader, source, repo, context, impls) do
    Dataloader.add_source(
      loader,
      source,
      Dataloader.Ecto.new(repo,
        query: fn
          schema, args ->
            module = Map.fetch!(impls, schema)
            query = Map.get(args, :query, schema)

            Coeus.Query.run(module, query, args)
        end,
        default_params: Coeus.Query.default_params(context)
      )
    )
  end
end
