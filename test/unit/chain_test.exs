defmodule ChainTest do
  use ExUnit.Case

  describe "chain" do
    test "can be used a pass arguments to a function call" do
      assert "
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        7 |> multiply(4)
      " |> Lunary.Main.eval() == 28
    end

    test "can be used to chain multiple function calls" do
      assert "
        fn add (param) -> ( 
          param + 1
        )
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        7 |> add |> multiply(2)
      " |> Lunary.Main.eval() == 16
    end

    test "can be assigned" do
      assert "
        fn add (param) -> ( 
          param + 1
        )
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        val = 7 |> add |> multiply(2)
        val
      " |> Lunary.Main.eval() == 16
    end

    test "can be assigned across multiple lines" do
      assert "
        fn add (param) -> ( 
          param + 1
        )
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        val = 7
        |> add
        |> multiply(2)
        val
      " |> Lunary.Main.eval() == 16
    end

    test "can be written across multiple lines" do
      assert "
        fn add (param) -> ( 
          param + 1
        )
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        7 
        |> add 
        |> multiply(2)
      " |> Lunary.Main.eval() == 16
    end

    test "can use a chain to pass an anonymous function inline as an argument" do
      assert "
        fn test (param) -> (param(100))
        (fn (param) -> (param + 1)) |> test
      " |> Lunary.Main.eval() == 101
    end

    test "can use functions from modules" do
      assert "
        mod @example (
          fn a param -> (param + 1)
          fn b param -> ((res: param * 100))
        )

        chain = 9
        |> @example.a()
        |> @example.b()

        chain.res
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 1000
    end
  end
end
