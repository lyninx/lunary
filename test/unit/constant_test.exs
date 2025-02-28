defmodule ConstantTest do
  use ExUnit.Case

  describe "constants" do
    test "can be assigned" do
      assert "
        ::( const: 100 )
        ::const
      " |> Lunary.Main.eval() == 100
    end

    test "can be assigned with whitespace around elements" do
      assert "
        ::( 
          const: 100 
        )
        ::const
      " |> Lunary.Main.eval() == 100
    end

    test "block can assign multiple values at once" do
      assert "
        ::( 
          const: 100,
          other_const: 25
        )
        ::const + ::other_const
      " |> Lunary.Main.eval() == 125
    end
    test "block can assign multiple values that accept identifiers" do
      assert "
        a = 50
        ::( 
          const: a,
          other_const: 100 
        )
        ::const + ::other_const
      " |> Lunary.Main.eval() == 150
    end
    
    test "block returns its contents" do
      assert "
        ::( 
          const: 100, 
          other_const: 0 
        )
      " |> Lunary.Main.eval() == %{"::const" => 100, "::other_const" => 0}
    end

    test "block evaluates expressions during assignment" do
      assert "
        ::( 
          const: (100 * 10), 
          other_const: (1000 / 2)
        )
      " |> Lunary.Main.eval() == %{"::const" => 1000, "::other_const" => 500.0}
    end

    test "cannot be reassigned" do
      assert_raise RuntimeError, "Constant ::const is already defined", fn -> "
          ::( const: 100 )
          ::( const: 200 )
          ::const
        " |> Lunary.Main.eval() end
    end

    test "cannot be mutated after being set" do
      assert "
          ::( const: 100 )
          const = 200
          ::const
        " |> Lunary.Main.eval() == 100
    end

    test "can be anonymous functions" do
      assert "
        ::(
          const_function: fn (param) -> (param + 1),
          const: 100
        )
        ::const_function(::const)
      " |> Lunary.Main.eval() == 101
    end

    test "have access to outside scope" do
      assert "
        some_value = 1
        ::(
          const: 100 + some_value
        )
        some_value = 2
        ::const
      " |> Lunary.Main.eval() == 101
    end

    test "error when constant is not defined" do
      assert_raise RuntimeError, "Constant ::const is not defined", fn -> "
          ::const
        " |> Lunary.Main.eval() end
    end
  end
end
