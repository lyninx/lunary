defmodule BooleanTest do
  use ExUnit.Case

  describe "boolean" do
    test "can be assigned as true" do
      assert "
        val = true
        val
      " |> Lunary.Main.eval() == true
    end

    test "can be assigned as false" do
      assert "
        val = false
        val
      " |> Lunary.Main.eval() == false
    end
  end

  describe "logical operators" do
    test "can be used to write complex logical statements" do
      assert "
        nil xor (true or not not false) or ()
      " |> Lunary.Main.eval() == true
    end
  end

  describe "logical operator not" do
    test "negates true" do
      assert "not true" |> Lunary.Main.eval() == false
    end
    test "negates false" do
      assert "not false" |> Lunary.Main.eval() == true
    end
    test "can be used as part of an assignment" do
      assert "
        val = not true
        val
      " |> Lunary.Main.eval() == false
    end
    test "can be chained" do
      assert "
        not not true
      " |> Lunary.Main.eval() == true
    end
    test "can be used with lists" do
      assert "
        not []
      " |> Lunary.Main.eval() == false
    end
    test "can be used with maps" do
      assert "
        not ()
      " |> Lunary.Main.eval() == false
    end
    test "can be used with nil" do
      assert "
        not nil
      " |> Lunary.Main.eval() == true
    end
  end

  describe "logical operator and" do
    test "handles simple and cases" do
      assert "true and true" |> Lunary.Main.eval() == true
      assert "false and true" |> Lunary.Main.eval() == false
      assert "true and false" |> Lunary.Main.eval() == false
      assert "false and false" |> Lunary.Main.eval() == false
    end
    test "works as part of an assignment" do
      assert "
        val = true and true
        val
      " |> Lunary.Main.eval() == true
    end
    test "can chain multiple ands" do
      assert "
        true and true and false
      " |> Lunary.Main.eval() == false
    end
    test "can use identifiers" do
      assert "
        true_value = true
        true_value and true_value
      " |> Lunary.Main.eval() == true
    end
    test "can use lists" do
      assert "
        true_value = []
        true_value and true and true
      " |> Lunary.Main.eval() == true
    end
    test "can use maps" do
      assert "
        () and true and true
      " |> Lunary.Main.eval() == true
    end
    test "can use nil" do
      assert "
        nil and true
      " |> Lunary.Main.eval() == nil
    end
    test "can use with other types" do
      assert "
        100 and nil
      " |> Lunary.Main.eval() == nil
    end
    test "returns last falsy value" do
      assert "
        0 and [] and nil and () and true
      " |> Lunary.Main.eval() == nil
    end
  end

  describe "logical operator or" do
    test "handles simple or cases" do
      assert ~s(true or true) |> Lunary.Main.eval() == true
      assert ~s(true or false) |> Lunary.Main.eval() == true
      assert ~s(false or true) |> Lunary.Main.eval() == true
      assert ~s(false or false) |> Lunary.Main.eval() == false
    end

    test "can be used as part of an assignment" do
      assert ~s(
        val = true or false
        val
      ) |> Lunary.Main.eval() == true
    end
    test "can chain multiple ors" do
      assert "
        true or false or false
      " |> Lunary.Main.eval() == true
    end
    test "can use identifiers" do
      assert "
        true_value = true
        true_value or false
      " |> Lunary.Main.eval() == true
    end
    test "can use lists" do
      assert "
        false or false or [false]
      " |> Lunary.Main.eval() == [false]
    end
    test "can use maps" do
      assert "
        () or false or false
      " |> Lunary.Main.eval() == %{}
    end
    test "can use nil" do
      assert "
        nil or true
      " |> Lunary.Main.eval() == true
    end
    test "can use with other types" do
      assert "
        nil or 100
      " |> Lunary.Main.eval() == 100
    end
    test "returns last truthy value" do
      assert "
        nil or false or () or true
      " |> Lunary.Main.eval() == %{}
    end
  end

  describe "logical operator xor" do
    test "handles simple xor cases" do
      assert ~s(true xor true) |> Lunary.Main.eval() == false
      assert ~s(true xor false) |> Lunary.Main.eval() == true
      assert ~s(false xor true) |> Lunary.Main.eval() == true
      assert ~s(false xor false) |> Lunary.Main.eval() == false
    end

    test "can be used as part of an assignment" do
      assert "
        val = true xor false
        val
      " |> Lunary.Main.eval() == true
    end

    test "can chain multiple xors" do
      assert "
        true xor false xor true
      " |> Lunary.Main.eval() == false
    end
    test "can use identifiers" do
      assert "
        true_value = true
        true_value or false
      " |> Lunary.Main.eval() == true
    end
    test "can use lists" do
      assert "
        true xor false xor [false]
      " |> Lunary.Main.eval() == false
    end
    test "can use maps" do
      assert "
        false xor false xor ()
      " |> Lunary.Main.eval() == true
    end
    test "can use nil" do
      assert "
        nil xor true
      " |> Lunary.Main.eval() == true
    end
    test "can use with other types" do
      assert "
        :yes xor false
      " |> Lunary.Main.eval() == true
    end
  end
end
