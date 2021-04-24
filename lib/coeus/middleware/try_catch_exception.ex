defmodule Coeus.Middleware.TryCatchException do
  @behaviour Absinthe.Middleware

  def rescue_exceptions(middleware_spec, opts \\ []) do
    reporter = Keyword.get(opts, :reporter, fn _ -> :ok end)

    {__MODULE__, {middleware_spec, reporter}}
  end

  @impl Absinthe.Middleware
  def call(%{context: %{rescue_exceptions?: true}} = resolution, {middleware_spec, reporter}) do
    execute(middleware_spec, resolution)
  rescue
    e ->
      reporter.(e, __STACKTRACE__)

      Absinthe.Resolution.put_result(
        resolution,
        {:error, Coeus.UnhandledError.exception(original_exception: e)}
      )
  end

  @impl Absinthe.Middleware
  def call(resolution, {middleware_spec, _reporter}) do
    execute(middleware_spec, resolution)
  end

  defp execute({{module, function}, config}, resolution) do
    apply(module, function, [resolution, config])
  end

  defp execute({module, config}, resolution) do
    apply(module, :call, [resolution, config])
  end

  defp execute(module, resolution) when is_atom(module) do
    apply(module, :call, [resolution, []])
  end

  defp execute(fun, resolution) when is_function(fun, 2) do
    fun.(resolution, [])
  end
end
