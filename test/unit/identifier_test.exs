defmodule IdentifierTest do
  use ExUnit.Case

  describe "identifiers" do
    test "can be assigned basic values" do
      assert "
        val = 100
        val

      " |> Lunary.Main.eval() == 100
    end

    test "can be reassigned" do
      assert "
        val = 100
        val = 200
        val
      " |> Lunary.Main.eval() == 200
    end

    @tag :skip
    test "can be an entire program" do
      assert "val=1000" |> Lunary.Main.eval() == 1000
    end

    test "can be assigned values from other identifiers" do
      assert """
        val = 100
        other_val = val
        other_val
      """ |> Lunary.Main.eval() == 100
    end

    test "return the value they are assigned" do
      assert "
        val = 100
      " |> Lunary.Main.eval() == 100
    end

    test "can be suffixed with ?" do
      assert "
        val? = 100
        val?
      " |> Lunary.Main.eval() == 100
    end

    test "can be suffixed with !" do
      assert "
        val! = 100
        val!
      " |> Lunary.Main.eval() == 100
    end

    test "will evaluate local function without arguments if possible" do
      assert "
        fn val -> (
          100
        )
        val
      " |> Lunary.Main.eval() == 100
    end
  end
end
