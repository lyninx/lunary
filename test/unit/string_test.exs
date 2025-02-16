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
      assert "\"🚀 works\"" |> Lunary.Main.eval() == "🚀 works"
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

    test "can interpolate strings" do
      assert ~s(
        val = "world"
        "hello {val}"
      ) |> Lunary.Main.eval() == "hello world"
    end

    test "can interpolate strings with expressions" do
      assert ~s(
        "hello {1 + 2}"
      ) |> Lunary.Main.eval() == "hello 3"
    end

    test "can interpolate strings with function calls" do
      assert ~s(
        fn test param -> \( 
          param + 100
        \)
        "hello {test 1 + 3}"
      ) |> Lunary.Main.eval() == "hello 104"
    end

    test "can interpolate strings multiple times" do
      assert ~s(
        hello = "hi"
        "{hello} {:true}{nil} world {[1,2,3] at 0}"
      ) |> Lunary.Main.eval() == "hi true world 1"
    end
  end
end