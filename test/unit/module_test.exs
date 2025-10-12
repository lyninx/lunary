defmodule ModuleTest do
  use ExUnit.Case

  describe "module" do
    test "can be autoloaded" do
      assert "
        use @math
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 19
    end

    test "can be loaded and called" do
      assert "
        use @math
        @math
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 19
    end

    test "can be explicitly loaded and called" do
      assert "
        @new_math = @kernel.load(\"math\")
        @new_math
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 19
    end

    test "can access nested results on maps" do
      assert "
        @mod = @kernel.load(\"object\")
        @mod.d.wrapper.result
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == :test
    end

    test "can access nested atoms with shorthand syntax on maps" do
      assert "
        @mod = @kernel.load(\"object\")
        @mod.d.wrapper.result
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == :test
    end

    test "can access nested atoms with mixed access syntax using keywords on maps" do
      assert "
        @mod = @kernel.load(\"object\")
        (:wrapper from @mod.d).result
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == :test
    end

    @tag :skip
    test "can be defined and accessed" do
      assert "
        test = \"meow\"
        mod @example (
          fn a param -> (param + 1)
          fn b param -> ((res: param * 100))
        )
        @example.a
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == {:fn, {:identifier, 4, "a"}, [{:identifier, 4, "param"}], [[{:add_op, {:identifier, 4, "param"}, {:int, 4, 1}}]]}
    end

    test "can be defined and called" do
      assert "
        test = \"meow\"
        mod @example (
          fn a param -> (param + 1)
          fn b param -> ((res: param * 100))
        )
        @example.a(2)
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 3
    end

    test "can be defined and called in a chain" do
      assert "
        test = \"meow\"
        fn bb param -> ((res: param * 100))
        mod @example (
          fn a param -> (param + 1)
          fn b param -> ((res: param * 100))
        )
        @example.b(2).res
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 200
    end
  end
end
