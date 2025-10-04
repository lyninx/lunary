defmodule FunctionTest do
  use ExUnit.Case

  describe "functions" do
    test "can be defined and called when within scope" do
      assert "
        fn test (param, param2) -> (
          (param + param2)
        )
        val = test (10, 20)
        val
      " |> Lunary.Main.eval() == 30
    end

    test "can be defined and returned as their AST representation" do
      expected =
        {:fn, {:identifier, 2, "test"}, [{:identifier, 2, "param"}],
         [[{:identifier, 2, "param"}]]}

      assert "
        fn test (param) -> (param)
        test
      " |> Lunary.Main.eval() == expected
    end

    test "can be defined without params" do
      assert "
        fn test -> (100)
        test
      " |> Lunary.Main.eval() == 100
    end

    test "can return values assigned to variables" do
      assert "
        fn test -> (
          result_value = 100
          some_other_value = 200
          result_value
        )
        test
      " |> Lunary.Main.eval() == 100
    end

    test "return their AST representation when defined" do
      expected =
        {:fn, {:identifier, 2, "test"}, [{:identifier, 2, "param"}],
         [[{:identifier, 2, "param"}]]}

      assert "
        fn test (param) -> (param)
      " |> Lunary.Main.eval() == expected
    end

    # todo: revise this
    test "inherit scope when called" do
      assert "
        fn test (param, param2) -> (
          param + param2 + external_value
        )
        val = 10
        val2 = 20
        external_value = 10
        test (val, val2)
      " |> Lunary.Main.eval() == 40
    end

    test "cannot call undefined functions" do
      assert_raise RuntimeError, "Function test is not defined", fn -> "
          test (10, 20)
        " |> Lunary.Main.eval()
      end
    end

    test "can evaluate expressions passed as arguments" do
      assert "
        fn test (param, param2) -> (
          param + param2
        )
        val = 1
        val2 = 100
        test (test (0, 1), (val2 * 10))
      " |> Lunary.Main.eval() == 1001
    end

    test "can be defined without brackets around params" do
      assert "
        fn test param, param2 -> (
          param + param2
        )
        val = 100
        val2 = 50
        test (val, val2)
      " |> Lunary.Main.eval() == 150
    end

    test "can be called without arguments" do
      assert "
        fn test -> (100)
        test
      " |> Lunary.Main.eval() == 100
    end

    test "can be called with any number of nil arguments" do
      assert "
        fn test -> (100)
        test(_,_,_)
      " |> Lunary.Main.eval() == 100
    end

    # test "can be called without brackets around arguments" do
    #   assert "
    #     fn test (param, param2) -> (
    #       param + param2
    #     )
    #     val = 100
    #     val2 = 50
    #     test val, val2
    #   " |> Lunary.Main.eval() == 150
    # end

    # test "can evaluate expressions passed as arguments without brackets " do
    #   assert "
    #     fn test param -> (
    #       param + 100
    #     )
    #     test test 800
    #   " |> Lunary.Main.eval() == 1000
    # end

    test "can be anonymous" do
      assert "
        a = 100
        val = fn (param) -> (param + 1)
        val(a)
      " |> Lunary.Main.eval() == 101
    end

    test "can be anonymous without arguments" do
      assert "
        func = fn -> (100)
        func(_)
      " |> Lunary.Main.eval() == 100
    end

    test "can return an anonymous function" do
      assert "
        fn -> (100)
      " |> Lunary.Main.eval() == {:fn, [], [[{:int, 2, 100}]]}
    end

    test "can return an anonymous function when assigned to an identifier" do
      assert "
        func = fn -> (100)
      " |> Lunary.Main.eval() == {:fn, [], [[{:int, 2, 100}]]}
    end

    test "can evaluate expressions as arguments" do
      assert "
        fn test param -> (
          param + 100
        )
        test(10 * 5)
      " |> Lunary.Main.eval() == 150
    end

    test "can pass an anonymous function inline as an argument" do
      assert "
        fn test (param) -> (param(100))
        test(fn (param) -> (param + 1))
      " |> Lunary.Main.eval() == 101
    end
  end
end
