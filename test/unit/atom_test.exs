defmodule AtomTest do
  use ExUnit.Case

  describe "atom" do
    test "can be assigned" do
      assert "
        val = :atom
        val
      " |> Lunary.Main.eval() == :atom
    end
  end
end
