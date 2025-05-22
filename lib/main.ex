defmodule Lunary.Main do
  require IEx
  def main([]), do: start_repl()

  def main(args) do
    filename = Enum.fetch!(args, 0)

    text = File.read!(filename)

    eval(text, %{}, %{debug: false}) |> IO.puts()
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
    # append newline to ensure program always ends with a newline
    processed_string = [string, ?\n]
      |> IO.iodata_to_binary
      |> String.to_charlist
      |> :lunary_lexer.string()

    with {:ok, tokens, _line} <- processed_string,
         {:ok, tree} <- :lunary_parser.parse(tokens) do
      if opts[:debug] == true, do: IO.inspect(tokens, pretty: true)
      Lunary.eval(tree, state, opts)
    else
      {:error, err} -> raise Lunary.ParseError, message: err
      err -> err
    end
  end
end

# todo:
# - add control flow
# - add support for tuples?
# - add default params
# - handle division by zero (:infinity/-:infinity/:nan)
# - fix repl (support fdef, error handling)
# - multi stage evaluator which outputs llvm IR (stretch goal)
