defmodule MapTest do
  use ExUnit.Case

  describe "map" do
    test "can be assigned" do
      assert "
        val = (a: 1, b: 2)
        val
      " |> Lunary.Main.eval() == %{a: 1, b: 2}
    end

    test "can span multiple lines" do
      assert "
        ( 
          a: 1
        )
      " |> Lunary.Main.eval() == %{a: 1}
    end

    test "can span multiple lines with multiple elements" do
      assert "
        ( 
          a: 1, 
          b: 2
        )
      " |> Lunary.Main.eval() == %{a: 1, b: 2}
    end

    test "can span multiple lines while ignoring additional newlines" do
      assert "
        ( 

          a: 1, 

          b: 2, z: 1000

        )
      " |> Lunary.Main.eval() == %{a: 1, b: 2, z: 1000}
    end

    test "can use string keys" do
      assert "
        (\"a\": 1, \"b\": 2, \"💙\": 3)
      " |> Lunary.Main.eval() == %{"a" => 1, "b" => 2, "💙" => 3}
    end

    test "can use list keys" do
      assert "
        ([1,2,3]: 1, [4,5,6]: 2)
      " |> Lunary.Main.eval() == %{[1, 2, 3] => 1, [4, 5, 6] => 2}
    end

    test "can use map keys" do
      assert "
        ((a:0, b:100): 1, b: 2)
      " |> Lunary.Main.eval() == %{%{a: 0, b: 100} => 1, b: 2}
    end

    test "can evalute expressions as values" do
      assert "
        val = (a: 1, b: 2 + 2)
        val
      " |> Lunary.Main.eval() == %{a: 1, b: 4}
    end

    test "can be accessed using the 'at' keyword" do
      assert "
        (a: 1, b: 2) at :a
      " |> Lunary.Main.eval() == 1
    end

    test "can be accessed as an identifier using the 'at' keyword" do
      assert "
        map = (a: 1, b: 2)
        map at :a
      " |> Lunary.Main.eval() == 1
    end

    test "can be accessed using the 'at' keyword with a string" do
      assert "
        (\"a\": 1, \"b\": 2) at \"b\"
      " |> Lunary.Main.eval() == 2
    end

    test "can be accessed using the 'at' keyword with an array" do
      assert "
        (a: 1, b: 2, z: 100) at [:a, :z, :a]
      " |> Lunary.Main.eval() == [1, 100, 1]
    end
  end
end
