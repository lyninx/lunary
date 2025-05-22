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

    @tag :skip
    test "can be combined with expressions" do
      assert "
        @something = use @math + 1
        @something
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 20
    end

    @tag :skip
    test "can be maps" do
      assert "
        use @math from (a: 1, b: 2)
        @math
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == %{ a: 1, b: 2 }
    end

    @tag :skip
    test "can be constant sets" do
      assert "
        use @stuff from &module
        use @math from (@stuff at :a)
        @math(99)
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 100
    end

    @tag :skip
    test "can access functions using 'at' keyword" do
      assert "
        use @mod from &module
        @mod at :a 99
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 100
    end

    @tag :skip
    test "can access functions using 'from' keyword" do
      assert "
        use @mod from &module
        yes = :c from @mod
        :res from (yes 2)
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 200
    end

    test "can access nested results" do
      assert "
        @mod = @kernel.load(\"module\")
        @mod.:d.:wrapper.:result
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == :test
    end

    test "can access nested atoms with shorthand syntax" do
      assert "
        @mod = @kernel.load(\"module\")
        @mod.d.wrapper.result
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == :test
    end

    test "can access nested atoms with mixed access syntax" do
      assert "
        @mod = @kernel.load(\"module\")
        @mod.d.:wrapper.result
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == :test
    end

    test "can access nested atoms with mixed access syntax using keywords" do
      assert "
        @mod = @kernel.load(\"module\")
        (:wrapper from @mod.d).result
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == :test
    end
  end
end
