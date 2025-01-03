defmodule ExpressionTest do
  use ExUnit.Case

  describe "expressions" do
    test "evaluate basic math" do
      assert "
        a = 100 + 100
      " |> Lunary.Main.eval() == 200
    end

    test "evaluates math using operator precedence " do
      assert "
        a = (10 + 20 - 30 * 40 / 50) + 94
      " |> Lunary.Main.eval() == 100
    end

    test "handle brackets correctly" do
      assert "
        ((100 * 5 + 10 / 2) - 5) / (1 + 4)
      " |> Lunary.Main.eval() == 100
    end

    test "can express as negative numbers" do
      assert "
        -100
      " |> Lunary.Main.eval() == -100
    end

    test "can evaluate arithmetic with negative numbers" do
      assert "
        -100 - -100
      " |> Lunary.Main.eval() == 0
    end

    # test "evaluate empty expression as nil" do
    #   assert "
    #     (((())))
    #   " |> Lunary.Main.eval() == nil
    # end
  end
end
