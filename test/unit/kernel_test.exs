defmodule KernelTest do
  use ExUnit.Case

  describe "kernel" do
    test "can load lunary files" do
      assert "
        res = @kernel.load(\"test/fixtures/object\")
        res.b
      " |> Lunary.Main.eval() == "test"
    end
  end
end
