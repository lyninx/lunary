defmodule NilTest do
  use ExUnit.Case

  describe "nil" do
    test "is nil" do
      assert "
        nil
      " |> Lunary.Main.eval() == nil
    end

    test "can be assigned" do
      assert "
        val = nil
        val
      " |> Lunary.Main.eval() == nil
    end

    test "can be used as a function argument" do
      assert "
        fn test (param) -> (param)
        test nil
      " |> Lunary.Main.eval() == nil
    end

    test "can be used as a constant" do
      assert "
        ::(
          const: nil
        )
        ::const
      " |> Lunary.Main.eval() == nil
    end

    test "returns itself when evaluated" do
      assert "
        nil
      " |> Lunary.Main.eval() == nil
    end
  end
end
