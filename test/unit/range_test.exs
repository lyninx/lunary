defmodule RangeTest do
  use ExUnit.Case

  describe "range" do
    test "can be assigned" do
      assert "
        val = 1~10
        val
      " |> Lunary.Main.eval() == Enum.to_list(1..10)
    end

    test "can be expressed as multiple expressions" do
      assert "
        fn test -> (1)
        val = (test _) ~ 5*2
        val
      " |> Lunary.Main.eval() == Enum.to_list(1..10)
    end
  end
end
