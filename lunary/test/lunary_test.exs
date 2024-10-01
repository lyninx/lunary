defmodule LunaryTest do
  use ExUnit.Case
  doctest Lunary
  describe "identifiers" do
    test "can be assigned basic values" do
      assert "
        val = 100
        val
      " |> Lunary.Main.eval == 100
    end

    test "can be reassigned" do
      assert "
        val = 100
        val = 200
        val
      " |> Lunary.Main.eval == 200
    end

    test "can be assigned values from other identifiers" do
      assert "
        val = 100
        other_val = val
        other_val
      " |> Lunary.Main.eval == 100
    end

      test "return the value they are assigned" do
      assert "
        val = 100
      " |> Lunary.Main.eval == 100
    end
  end

  describe "constants" do
    test "can be assigned" do
      assert "
        //( const: 100 )
        ::const
      " |> Lunary.Main.eval == 100
    end

    @tag :skip
    test "block can assign multiple values at once" do
      assert "
        //( 
          const: 100 
          other_const: 0 
        )
        ::other_const
      " |> Lunary.Main.eval == 0
    end
  end

  describe "expressions" do
    test "handle maths correctly" do
      assert "
        ((100 * 5 + 10 / 2) - 5) / 5
      " |> Lunary.Main.eval == 100
    end
  end

  describe "functions" do
    test "can be defined and called when within scope" do
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
