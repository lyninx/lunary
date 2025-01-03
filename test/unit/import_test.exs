defmodule ImportTest do
  use ExUnit.Case

  describe "import" do
    test "can be loaded" do
      assert "
        &math
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 19
    end
    test "can be loaded using a path" do
      # depends on math.lun
      assert "
        &test/fixtures/math
      " |> Lunary.Main.eval() == 19
    end
    test "can be assigned" do
      assert "
        val = &test/fixtures/math
        val
      " |> Lunary.Main.eval() == 19
    end
  end
end
