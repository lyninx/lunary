defmodule AtomTest do
  use ExUnit.Case

  describe "atom" do
    test "can be assigned" do
      assert "
        val = :atom
        val
      " |> Lunary.Main.eval() == :atom
    end

    test "can contain underscores and numbers" do
      assert "
        val = :atom_with_123
        val
      " |> Lunary.Main.eval() == :atom_with_123
    end
  end
end
