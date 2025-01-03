defmodule BooleanTest do
  use ExUnit.Case

  describe "boolean" do
    test "can be assigned as true" do
      assert "
        val = true
        val
      " |> Lunary.Main.eval() == true
    end

    test "can be assigned as false" do
      assert "
        val = false
        val
      " |> Lunary.Main.eval() == false
    end
  end
end
