defmodule Files do
  def load(path) when is_binary(path) do
    case File.read(path) do
      # {:ok, data} -> :erlang.binary_to_term(data)
      {:ok, data} -> String.split(data, "\n", trim: true)
      {:error, _} -> []
    end
  end

  def save(path, data) when is_binary(path) and is_binary(path) do
    # bin = :erlang.term_to_binary(data); File.write(path, bin)
    # case File.write(path, bin) do
    #  :ok -> "Ok"
    #  {:error, _} -> "Error"
    # end

    case File.write(path, data) do
      :ok -> "Ok"
      {:error, _} -> "Error"
    end
  end
end
