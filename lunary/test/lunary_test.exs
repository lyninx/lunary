defmodule LunaryTest do
  use ExUnit.Case
  doctest Lunary
  describe "identifier assignment" do
    test "handles basic value assignment" do
      assert "
        val = 100
        val
      " |> Lunary.Main.eval == 100
    end
  end

  describe "constant assignment" do
    test "handles constant assignment" do
      assert "
        //( const: 100 )
        ::const
      " |> Lunary.Main.eval == 100
    end

    @tag :skip
    test "handles multiple constant assignment" do
      assert "
        //( 
          const: 100 
          other_const: 0 
        )
        ::other_const
      " |> Lunary.Main.eval == 0
    end
  end

  describe "expression evaluation" do
    test "handles maths correctly" do
      assert "
        ((100 * 5 + 10 / 2) - 5) / 5
      " |> Lunary.Main.eval == 100
    end
  end

  describe "function evaluation" do
    test "handles named function definition and calling" do
      assert "
        \\> test (param, param2) -> ( 
          (param + param2)
        ) 
        val = /> test (10, 20)
        val
      " |> Lunary.Main.eval == 30
    end
  end
end
