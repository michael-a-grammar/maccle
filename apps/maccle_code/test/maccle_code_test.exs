defmodule MaccleCodeTest do
  use ExUnit.Case
  doctest MaccleCode

  test "greets the world" do
    assert MaccleCode.hello() == :world
  end
end
