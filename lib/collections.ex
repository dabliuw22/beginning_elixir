defmodule Collections do
  defp isGt?(item, value) when is_binary(item) and is_integer(value) do
    String.length(item) >= value
  end

  def list do
    nums = ["One", "Two", "Three"]
    colors = ["Red", "Blue"]
    isGt3 = Enum.all?(nums, &isGt?(&1, 3))
    IO.puts(isGt3)

    mul = fn a ->
      fn b -> a * b end
    end

    # mul = &(&1 * &2)

    numsMul = Enum.map([0, 1, 2, 3], mul.(2))

    Enum.each(numsMul, fn item -> IO.puts(item) end)

    lis =
      for color <- colors do
        for num <- nums do
          "#{color}-#{num}"
        end
      end

    IO.puts(lis)

    lis2 =
      for color <- colors, num <- nums do
        "#{color}-#{num}"
      end

    Enum.shuffle(List.flatten(lis2))
  end

  def map do
    # m = %{:key => "1234", :name => "Name"}
    m = %{key: "1234", name: "Name"}
    IO.puts(m.key)
    IO.puts(m[:name])
    # %{key: k, name: _} = %{m | :name => "New Name"}
    %{key: k, name: n} = Map.put(m, :name, "New Name")
    IO.puts(n)
    k
  end

  def tuple do
    tu = {1, :two, "three"}
    item = elem(tu, 2)
    IO.puts(item)
    {h, _} = Enum.split(list(), 2)
    h
  end
end
