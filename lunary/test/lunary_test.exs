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

    test "block can assign multiple values at once" do
      assert "
        //( 
          const: 100 
          other_const: 0 
        )
        ::other_const
      " |> Lunary.Main.eval == 0
    end

    test "return their last assigned value" do
      assert "
        //( 
          const: 100 
          other_const: 0 
        )
      " |> Lunary.Main.eval == 0
    end

    test "evaluate expressions during assignment" do
      assert "
        //( 
          const: (100 * 10) 
          other_const: (1000 / 2)
        )
      " |> Lunary.Main.eval == 500
    end

    test "cannot be reassigned" do
      assert_raise RuntimeError, "Constant ::const is already defined", fn -> "
          //( const: 100 )
          //( const: 200 )
          ::const
        " |> Lunary.Main.eval
      end
    end
  end

  describe "expressions" do
    test "does addition correctly" do
      assert "
        a = 100 + 100
      " |> Lunary.Main.eval == 200
    end

    test "handle maths correctly" do
      assert "
        ((100 * 5 + 10 / 2) - 5) / 5
      " |> Lunary.Main.eval == 100
    end

    test "can express as negative numbers" do
      assert "
        -100
      " |> Lunary.Main.eval == -100
    end

    test "can evaluate arithmetic with negative numbers" do
      assert "
        -100 - -100
      " |> Lunary.Main.eval == 0
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

    test "inherit scope when called" do
      assert "
        \\> test (param, param2) -> ( 
          param + param2 + external_value
        ) 
        val = 10
        val2 = 20
        external_value = 10
        /> test (val, val2)
      " |> Lunary.Main.eval == 40
    end

    test "cannot mutate externally scoped identifiers" do
      assert "
        \\> test (param, param2) -> ( 
          res = param + param2 + external_value
          external_value = 999
          res
        ) 
        val = 10
        val2 = 20
        external_value = 10
        /> test (val, val2)
        external_value
      " |> Lunary.Main.eval == 10
    end

    test "can evaluate expressions passed as arguments" do
      assert "
        \\> test (param, param2) -> ( 
          res = param + param2
          external_value = 999
          res
        ) 
        val = 1
        val2 = 100
        /> test (/> test (0, 1), (val2 * 10))
      " |> Lunary.Main.eval == 1001
    end

    test "can be defined without brackets around params" do
      assert "
        \\> test param, param2 -> ( 
          param + param2
        ) 
        val = 100
        val2 = 50
        /> test (val, val2)
      " |> Lunary.Main.eval == 150
    end

    test "can be called without brackets around arguments" do
      assert "
        \\> test (param, param2) -> ( 
          param + param2
        ) 
        val = 100
        val2 = 50
        /> test val, val2
      " |> Lunary.Main.eval == 150
    end

    test "can evaluate expressions passed as arguments without brackets " do
      assert "
        \\> test param -> ( 
          param + 100
        ) 
        /> test /> test 800
      " |> Lunary.Main.eval == 1000
    end
  end
end
