defmodule Coeus.Schema do
  defmacro __using__(_opts) do
    quote do
      @pipeline_modifier unquote(__MODULE__)

      use Absinthe.Schema
      use Coeus.Schema.Notation

      import_types Absinthe.Type.Custom
      import_types Coeus.Types
      import_types Coeus.Connection.Types
    end
  end

  def pipeline(pipeline) do
    Absinthe.Pipeline.insert_after(pipeline, Absinthe.Phase.Schema.TypeImports, __MODULE__.Phase)
  end
end
