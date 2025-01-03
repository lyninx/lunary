defmodule ListTest do
  use ExUnit.Case

  describe "list" do
    test "can be assigned" do
      assert "
        val = [1000]
        val
      " |> Lunary.Main.eval() == [1000]
    end

    test "can be assigned multiple elements" do
      assert "
        val = [0, 1000]
        val
      " |> Lunary.Main.eval() == [0, 1000]
    end

    test "can be nested" do
      assert "
        val = [[]]
        val
      " |> Lunary.Main.eval() == [[]]
    end

    test "can be nested with multiple elements" do
      assert "
        val = [[], 1000]
        val
      " |> Lunary.Main.eval() == [[], 1000]
    end

    test "can access a single element using the 'at' keyword" do
      assert "
        [1,2,3,4] at 0
      " |> Lunary.Main.eval() == 1
    end

    test "can be accessed as an identifier using the 'at' keyword" do
      assert "
        list = [\"a\", \"b\", \"c\"]
        list at 2
      " |> Lunary.Main.eval() == "c"
    end

    test "can access a slice using the 'at' keyword with a range" do
      assert "
        [1,2,3,4] at 2~3
      " |> Lunary.Main.eval() == [3, 4]
    end

    test "can access a slice using the 'at' keyword with a list" do
      assert "
        [1,2,3,4] at [3,-5,-1,-1,0,2,3,4]
      " |> Lunary.Main.eval() == [4, nil, 4, 4, 1, 3, 4, nil]
    end
  end
end
