defmodule ChainTest do
  use ExUnit.Case

  describe "chain" do
    test "can be used a pass arguments to a function call" do
      assert "
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        7 |> multiply(4)
      " |> Lunary.Main.eval() == 28
    end

    test "can be used to chain multiple function calls" do
      assert "
        fn add (param) -> ( 
          param + 1
        )
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        7 |> add |> multiply(2)
      " |> Lunary.Main.eval() == 16
    end

    test "can be assigned" do
      assert "
        fn add (param) -> ( 
          param + 1
        )
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        val = 7 |> add |> multiply(2)
        val
      " |> Lunary.Main.eval() == 16
    end

    test "can be assigned across multiple lines" do
      assert "
        fn add (param) -> ( 
          param + 1
        )
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        7
        |> add
        |> multiply(2)
      " |> Lunary.Main.eval() == 16
    end

    test "can be written across multiple lines" do
      assert "
        fn add (param) -> ( 
          param + 1
        )
        fn multiply (param, multiplier) -> ( 
          param * multiplier
        )
        7 
        |> add 
        |> multiply(2)
      " |> Lunary.Main.eval() == 16
    end

    test "can use a chain to pass an anonymous function inline as an argument" do
      assert "
        fn test (param) -> (param(100))
        (fn (param) -> (param + 1)) |> test
      " |> Lunary.Main.eval() == 101
    end

    test "can use functions from modules" do
      assert "
        mod @example (
          fn a (param) -> (param + 1)
          fn b (param,param2) -> ((res: param * param2))
        )

        chain = 9
        |> @example.a()
        |> @example.b(100)

        chain.res
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/"}) == 1000
    end

    test "can use functions from modules?" do
      assert "
        mod @html (
          fn html (head,body) -> (
            \"<!DOCTYPE html><html>\#{head}\#{body}</html>\"
          )
          fn head (styles, title) -> (
            \"<head><title>\#{title}</title><style>\#{styles}</style></head>\"
          )
          fn body (content) -> (
            \"<body><div>\#{content}</div></body>\"
          )
        )
        pageBody = @html.body(\"content\")
        \"styles\" |> @html.head(\"pageTitle\") |> @html.html(pageBody)
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == "<!DOCTYPE html><html><head><title>pageTitle</title><style>styles</style></head><body><div>content</div></body></html>"
    end

    test "can use 0-arity functions from modules" do
      assert "
        mod @example (
          fn a param -> (param + 1)
          fn b param -> ((res: param * 100))
        )

        98
        |> @example.a()
        |> @example.a()
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 100
    end

    # @tag :skip
    test "can use nested module functions" do
      assert "
        mod @example (
          fn func param -> (param + 1)
          fn a param -> (
            func(param)
          )
        )

        @example.a(99)
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 100
    end

    test "can use nested module functions (fully qualified)" do
      assert "
        mod @example (
          fn func param -> (param + 1)
          fn a param -> (
            @example.func(param)
          )
        )

        @example.a(99)
      " |> Lunary.Main.eval(%{}, %{ path: "test/fixtures/" }) == 100
    end
  end
end
