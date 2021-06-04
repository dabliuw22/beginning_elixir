defmodule BeginningElixirTest do
  use ExUnit.Case
  doctest BeginningElixir

  test "greets the world" do
    name = "Name"
    assert BeginningElixir.hello(name) == "Hello World #{name}"
  end

  test "one plus one is two" do
    assert 1 + 1 == 2
  end
end
