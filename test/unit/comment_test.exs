defmodule CommentTest do
  use ExUnit.Case

  describe "comment" do
    test "can be used to write comments" do
      assert "
        # this is a comment
        100
      " |> Lunary.Main.eval() == 100
    end
    test "can be used to write multiline comments" do
      assert "
        # this is a comment
        # this is another comment
        100
      " |> Lunary.Main.eval() == 100
    end
    test "can include multiple #" do
      assert "
        ## this is a comment #
        100
      " |> Lunary.Main.eval() == 100
    end
    test "can include emoji and other unicode characters" do
      assert "
        # 🚀 月
        100
      " |> Lunary.Main.eval() == 100
    end
    test "can be empty" do
      assert "
        #
        100
      " |> Lunary.Main.eval() == 100
    end
    test "returns nil" do
      assert "
        #comment
      " |> Lunary.Main.eval() == nil
    end
    test "cannot be used in place of an expression" do
      assert_raise Lunary.ParseError, fn -> "
        value = #comment
      " |> Lunary.Main.eval() end
    end
  end
end
