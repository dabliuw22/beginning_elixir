defmodule PatternMatching do
  @moduledoc """
  Provides methods for PM
  """

  @doc """
  Print list
  """
  def print_list([head | tail]) when is_number(head) do
    IO.puts(head)
    print_list(tail)
  end

  def print_list([]) do
    :ok
  end

  @doc """
  Sum list
  """
  def sum_list(list, accum \\ 0) when is_list(list) do
    case list do
      [h | t] -> sum_list(t, accum + h)
      [] -> accum
    end
  end

  @doc """
  Print tuple
  """
  def print_tuple(tuple) do
    f = fn {a, b} = _ ->
      IO.puts("#{a}, #{b}")
      :ok
    end

    f.(tuple)
  end
end
