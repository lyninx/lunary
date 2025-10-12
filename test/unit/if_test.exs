defmodule IfTest do
  use ExUnit.Case

  describe "if" do
    test "can be applied to a statemenet" do
      assert "
        val = 100 if true
        val
      " |> Lunary.Main.eval() == 100
    end

    test "can prevent a statement from being evaluated" do
      assert "
        val = 100
        val = 0 if false
        val
      " |> Lunary.Main.eval() == 100
    end
  end
end
