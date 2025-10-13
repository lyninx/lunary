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

    test "can be access using the 'from' keyword" do
      assert "
        :a from (a: 1, b: 2)
      " |> Lunary.Main.eval() == 1
    end

    test "can be accessed as an identifier using the 'from' keyword" do
      assert "
        map = (a: 1, b: 2)
        :a from map
      " |> Lunary.Main.eval() == 1
    end

    test "can be accessed using the 'from' keyword with a string" do
      assert "
        \"b\" from (\"a\": 1, \"b\": 2)
      " |> Lunary.Main.eval() == 2
    end

    test "can be accessed using the 'from' keyword with an array" do
      assert "
        [:a, :z, :a] from (a: 1, b: 2, z: 100)
      " |> Lunary.Main.eval() == [1, 100, 1]
    end

    test "can contain function definitions" do
      assert "
        map = (a: fn param -> (param + 1))
        func = map at :a
        func(100)
      " |> Lunary.Main.eval() == 101
    end

    test "can contain function definitions and be accessed using dot syntax" do
      assert "
        map = (a: fn param -> (param + 1))
        map.a
      " |> Lunary.Main.eval() == {:fn, [{:identifier, 2, "param"}], [[{:add_op, {:identifier, 2, "param"}, {:int, 2, 1}}]]}
    end

    @tag :skip
    test "can contain function definitions and be called using dot syntax" do
      assert "
        map = (a: fn param -> (param + 1))
        map.a(100)
      " |> Lunary.Main.eval() == 101
    end

    test "can set an value for a key" do
      assert "
        map = (a: 1, b: 2)
        map = map at :a <- 100
        map
      " |> Lunary.Main.eval() == %{a: 100, b: 2}
    end

    test "can set a value for a new key" do
      assert "
        map = (a: 1, b: 2)
        map = map at :c <- 100
        map.c
      " |> Lunary.Main.eval() == 100
    end
  end
end
