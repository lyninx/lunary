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

    test "can contain newlines" do
      assert "
        val = [
          0,
          1000
        ]
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
        [10,20,30,40] at 2~3
      " |> Lunary.Main.eval() == [30, 40]
    end

    test "can access a slice using the 'at' keyword with a list" do
      assert "
        [1,2,3,4] at [3,-5,-1,-1,0,2,3,4]
      " |> Lunary.Main.eval() == [4, nil, 4, 4, 1, 3, 4, nil]
    end

    test "can access a single element using the 'from' keyword" do
      assert "
        0 from [1,2,3,4]
      " |> Lunary.Main.eval() == 1
    end

    test "can be accessed as an identifier using the 'from' keyword" do
      assert "
        list = [\"a\", \"b\", \"c\"]
        2 from list
      " |> Lunary.Main.eval() == "c"
    end

    test "can access a slice using the 'from' keyword with a range" do
      assert "
        2~3 from [10,20,30,40]
      " |> Lunary.Main.eval() == [30, 40]
    end

    test "can set an value for an element" do
      assert "
        list = [1, 2, 3]
        list = list at 1 <- 42
        list
      " |> Lunary.Main.eval() == [1, 42, 3]
    end
  end
end
