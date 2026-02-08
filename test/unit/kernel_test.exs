defmodule KernelTest do
  use ExUnit.Case

  describe "kernel" do
    test "can load lunary files" do
      assert "
        res = @kernel.load(\"test/fixtures/object\")
        res.b
      " |> Lunary.Main.eval() == "test"
    end

    test "can load raw files" do
      assert "
        res = @kernel.load_raw(\"test/fixtures/raw.txt\")
        res
      " |> Lunary.Main.eval() == "this is a raw file...\n"
    end
  end
end
