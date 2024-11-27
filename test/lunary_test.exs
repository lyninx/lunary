defmodule LunaryTest do
  use ExUnit.Case
  doctest Lunary

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

    test "can be assigned values from other identifiers" do
      assert "
        val = 100
        other_val = val
        other_val
      " |> Lunary.Main.eval() == 100
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
  end

  describe "constants" do
    test "can be assigned" do
      assert "
        //( const: 100 )
        ::const
      " |> Lunary.Main.eval() == 100
    end

    test "block can assign multiple values at once" do
      assert "
        //( 
          const: 100 
          other_const: 25 
        )
        ::const + ::other_const
      " |> Lunary.Main.eval() == 125
    end
    test "block can assign multiple values that accept identifiers" do
      assert "
        a = 50
        //( 
          const: a other_const: 100 
        )
        ::const + ::other_const
      " |> Lunary.Main.eval() == 150
    end

    test "block returns last assigned value" do
      assert "
        //( 
          const: 100 
          other_const: 0 
        )
      " |> Lunary.Main.eval() == 0
    end

    test "block evaluates expressions during assignment" do
      assert "
        //( 
          const: (100 * 10) 
          other_const: (1000 / 2)
        )
      " |> Lunary.Main.eval() == 500
    end

    test "cannot be reassigned" do
      assert_raise RuntimeError, "Constant ::const is already defined", fn -> "
          //( const: 100 )
          //( const: 200 )
          ::const
        " |> Lunary.Main.eval() end
    end

    test "cannot be mutated after being set" do
      assert "
          //( const: 100 )
          const = 200
          ::const
        " |> Lunary.Main.eval() == 100
    end

    test "can be anonymous functions" do
      assert "
        //(
          const_function: \\> (param) -> (param + 1)
          const: 100
        )
        /> ::const_function(::const)
      " |> Lunary.Main.eval() == 101
    end

    test "error when constant is not defined" do
      assert_raise RuntimeError, "Constant ::const is not defined", fn -> "
          ::const
        " |> Lunary.Main.eval() end
    end
  end

  describe "expressions" do
    test "evaluate basic math" do
      assert "
        a = 100 + 100
      " |> Lunary.Main.eval() == 200
    end

    test "evaluates math using operator precedence " do
      assert "
        a = (10 + 20 - 30 * 40 / 50) + 94
      " |> Lunary.Main.eval() == 100
    end

    test "handle brackets correctly" do
      assert "
        ((100 * 5 + 10 / 2) - 5) / (1 + 4)
      " |> Lunary.Main.eval() == 100
    end

    test "can express as negative numbers" do
      assert "
        -100
      " |> Lunary.Main.eval() == -100
    end

    test "can evaluate arithmetic with negative numbers" do
      assert "
        -100 - -100
      " |> Lunary.Main.eval() == 0
    end

    test "evaluate empty expression as nil" do
      assert "
        (((())))
      " |> Lunary.Main.eval() == nil
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
      " |> Lunary.Main.eval() == 30
    end

    test "can be defined and returned as their AST representation" do
      expected =
        {:fn, {:identifier, 2, "test"}, [{:identifier, 2, "param"}],
         [[{:identifier, 2, "param"}]]}

      assert "
        \\> test (param) -> (param) 
        test
      " |> Lunary.Main.eval() == expected
    end

    test "can be defined without params" do
      assert "
        \\> test -> (100)
        /> test _
      " |> Lunary.Main.eval() == 100
    end

    test "return their AST representation when defined" do
      expected =
        {:fn, {:identifier, 2, "test"}, [{:identifier, 2, "param"}],
         [[{:identifier, 2, "param"}]]}

      assert "
        \\> test (param) -> (param) 
      " |> Lunary.Main.eval() == expected
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
      " |> Lunary.Main.eval() == 40
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
      " |> Lunary.Main.eval() == 10
    end

    test "cannot call undefined functions" do
      assert_raise RuntimeError, "Function test is not defined", fn -> "
          /> test (10, 20)
        " |> Lunary.Main.eval() 
      end
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
      " |> Lunary.Main.eval() == 1001
    end

    test "can be defined without brackets around params" do
      assert "
        \\> test param, param2 -> ( 
          param + param2
        ) 
        val = 100
        val2 = 50
        /> test (val, val2)
      " |> Lunary.Main.eval() == 150
    end

    test "can be called with a nil argument" do
      assert "
        \\> test -> (100)
        /> test _
      " |> Lunary.Main.eval() == 100
    end

    test "can be called with nil arguments" do
      assert "
        \\> test -> (100)
        /> test _,_,_
      " |> Lunary.Main.eval() == 100
    end

    test "can be called without brackets around arguments" do
      assert "
        \\> test (param, param2) -> ( 
          param + param2
        ) 
        val = 100
        val2 = 50
        /> test val, val2
      " |> Lunary.Main.eval() == 150
    end

    test "can evaluate expressions passed as arguments without brackets " do
      assert "
        \\> test param -> (
          param + 100
        )
        /> test /> test 800
      " |> Lunary.Main.eval() == 1000
    end

    test "can be anonymous" do
      assert "
        a = 100
        val = \\> (param) -> (param + 1)
        /> val(a)
      " |> Lunary.Main.eval() == 101
    end

    test "can evaluate ambiguous expressions as arguments" do
      assert "
        \\> test param -> ( 
          param + 100
        ) 
        /> test 10 * 5
      " |> Lunary.Main.eval() == 150
    end
  end

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
        \\> test (param) -> (param)
        /> test nil
      " |> Lunary.Main.eval() == nil
    end

    test "can be used as a constant" do
      assert "
        //(
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

  describe "string" do
    test "can be assigned" do
      assert "
        val = \"hello\"
        val
      " |> Lunary.Main.eval() == "hello"
    end
  end

  describe "array" do
    test "can be assigned" do
      assert "
        val = [1000]
        val
      " |> Lunary.Main.eval() == [1000]
    end

    test "can be assigned multiple elements" do
      assert "
        val = [0, 1000]
        val
      " |> Lunary.Main.eval() == [0, 1000]
    end

    test "can be nested" do
      assert "
        val = [[]]
        val
      " |> Lunary.Main.eval() == [[]]
    end

    test "can be nested with multiple elements" do
      assert "
        val = [[], 1000]
        val
      " |> Lunary.Main.eval() == [[], 1000]
    end
  end

  describe "module" do
    test "can be loaded" do
      assert "
        &math
      " |> Lunary.Main.eval(%{}, %{ path: "test/" }) == 19
    end
    test "can be loaded using a path" do
      # depends on math.lun
      assert "
        &test/math
      " |> Lunary.Main.eval() == 19
    end
    test "can be assigned" do
      assert "
        val = &test/math
        val
      " |> Lunary.Main.eval() == 19
    end
  end
end
