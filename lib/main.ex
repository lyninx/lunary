defmodule Lunary.Main do
  def main([]), do: start_repl()

  def main(args) do
    filename = Enum.fetch!(args, 0)

    IO.puts("Parsing #{filename}")
    text = File.read!(filename)

    {:ok, tokens, line} = :lunary_lexer.string(String.to_charlist(text))
    IO.puts("Parsed #{filename}, stopped at line #{line}")
    IO.puts("\nTokens:")
    IO.inspect(tokens, pretty: true)

    :lunary_parser.parse(tokens)
  end

  def start_repl do
    IO.puts("welcome to lunary!")
    IO.puts("type 'exit' to quit")
    loop(%{})
  end

  defp loop(state) do
    IO.write("lun> ")
    input = IO.gets("") |> String.trim()

    case input do
      "exit" ->
        IO.puts("bye bye")

      _ ->
        try do
          {result, scope} = eval(input, state, %{mode: :repl})
          IO.puts("> #{inspect(result)}")
          IO.inspect(scope)
          loop(scope)
        rescue
          e in RuntimeError ->
            IO.puts("Error: #{e.message}")
            loop(state)
        end
    end
  end

  def eval(string, state \\ %{}, opts \\ %{}) do
    with {:ok, tokens, _line} <- String.to_charlist(string) |> :lunary_lexer.string(),
         {:ok, tree} <- :lunary_parser.parse(tokens) do
      if opts[:debug] == true, do: IO.inspect(tokens, pretty: true)
      Lunary.eval(tree, state, opts)
    else
      err -> err
    end
  end
end

# todo:
# - add support for string literals
# - add | operator for function chaining
# - add support for tuples / hashmaps / lists ?
# - add default params
# - add control flow
# - handle division by zero (:infinity/-:infinity/:nan)
# - fix repl (support fdef, error handling)
# - multi stage evaluator which outputs llvm IR
