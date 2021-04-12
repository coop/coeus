defmodule Coeus.UnhandledError do
  defexception [:original_exception]

  @impl Exception
  def message(_ex) do
    "Sorry, something went wrong - if this error persists please contact support"
  end
end
