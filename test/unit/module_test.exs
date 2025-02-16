defmodule ModuleTest do
  use ExUnit.Case

  describe "module" do
    test "can be loaded" do
      assert "
        use @math from &math
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 19
    end

    test "can be loaded and called" do
      assert "
        use @math from &math
        @math
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 19
    end

    test "can be arbitrary expressions" do
      assert "
        use @math from (&math + 1)
        @math
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 20
    end

    test "can be maps" do
      assert "
        use @math from (a: 1, b: 2)
        @math
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == %{ a: 1, b: 2 }
    end

    test "can be constant sets" do
      assert "
        use @stuff from &module
        use @math from (@stuff at :a)
        @math(99)
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 100
    end
  end
end
