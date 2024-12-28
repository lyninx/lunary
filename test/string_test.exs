defmodule StringTest do
  use ExUnit.Case

  describe "String" do
    test "noop" do
      assert "\"100\"" |> Lunary.Main.eval() == "100"
    end
  end
end