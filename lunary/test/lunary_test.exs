defmodule LunaryTest do
  use ExUnit.Case
  doctest Lunary

  test "greets the world" do
    assert Lunary.hello() == :world
  end
end
