defmodule StringTest do
  use ExUnit.Case

  describe "string" do
    test "can be assigned" do
      assert "
        val = \"hello\"
        val
      " |> Lunary.Main.eval() == "hello"
    end

    test "supports unicode strings" do
      assert ~s("🚀 works") |> Lunary.Main.eval() == "🚀 works"
    end

    test "can access a single character using the 'at' keyword" do
      assert "
        \"abcd\" at 0
      " |> Lunary.Main.eval() == "a"
    end

    test "can access a slice using the 'at' keyword with a range" do
      assert "
        \"abcd\" at 2~3
      " |> Lunary.Main.eval() == "cd"
    end

    test "can access a slice using the 'at' keyword with a list" do
      assert "
        \"abcd\" at [3,-5,-1,-1,0,2,3,4]
      " |> Lunary.Main.eval() == "dddacd"
    end
  end
end