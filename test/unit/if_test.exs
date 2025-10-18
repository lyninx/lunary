defmodule IfTest do
  use ExUnit.Case

  describe "if" do
    test "can be applied to a statement" do
      assert "
        val = 100 if true
        val
      " |> Lunary.Main.eval() == 100
    end

    test "can prevent a statement from being evaluated" do
      assert "
        val = 100
        val = 0 if false
        val
      " |> Lunary.Main.eval() == 100
    end

    test "can be combined with an inline chain" do
      assert "
        fn double (x) -> ( x * 2 )
        fn invert (x) -> ( not x )

        val = 100 |> double() if not false
        val
      " |> Lunary.Main.eval() == 200
    end
  end

  describe "unless" do
    test "can be applied to a statement" do
      assert "
        val = 100 unless false
        val
      " |> Lunary.Main.eval() == 100
    end

    test "can prevent a statement from being evaluated" do
      assert "
        val = 100
        val = 0 unless true
        val
      " |> Lunary.Main.eval() == 100
    end
  end
end
