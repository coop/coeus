defmodule Coeus.Middleware.FormatErrors do
  @behaviour Absinthe.Middleware

  @impl Absinthe.Middleware
  def call(%{errors: errors} = resolution, _) do
    errors = Enum.flat_map(errors, &format_error/1)

    Absinthe.Resolution.put_result(resolution, {:error, errors})
  end

  def format_error(%Ecto.Changeset{valid?: false} = changeset) do
    changeset
    |> transform_changeset_errors()
    |> format_changeset_errors()
  end

  def format_error(exception) when is_exception(exception) do
    [%{message: Exception.message(exception)}]
  end

  def format_error(error) when is_atom(error) do
    [%{message: error}]
  end

  def format_error(error), do: [%{message: error}]

  defp transform_changeset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map(fn {field, messages} ->
      {field,
       Enum.map(messages, fn message ->
         case String.split(to_string(field), "_") do
           [first | []] ->
             first = String.capitalize(first)
             Enum.join([first, message], " ")

           [first | rest] ->
             first = String.capitalize(first)
             Enum.join([first] ++ rest ++ [message], " ")
         end
       end)}
    end)
  end

  defp format_changeset_errors(errors) do
    Enum.flat_map(errors, fn {attr, errors} ->
      Enum.map(errors, fn e -> %{message: e, path: [attr]} end)
    end)
  end
end
