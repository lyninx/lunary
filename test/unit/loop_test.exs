defmodule LoopTest do
  use ExUnit.Case

  describe "loop" do
    test "can be used to create a for loop" do
      assert "
        sum = 0
        for i in 1~5 -> (
          sum = sum + i
        )
        sum
      " |> Lunary.Main.eval() == 15
    end

    test "can be used to loop with conditionals" do
      assert "
        count = 0
        for i in [true, true, false] -> (
          count = count + 1 if i
        )
        count
      " |> Lunary.Main.eval() == 2
    end
  end
end