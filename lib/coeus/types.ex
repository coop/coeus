defmodule Coeus.Types do
  use Absinthe.Schema.Notation

  enum :sort_direction do
    value :asc
    value :desc
  end
end
