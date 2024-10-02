defmodule Lunary.Main do
  @moduledoc """
  Documentation for `Lunary`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Lunary.hello()
      :world

  """
  def process_parse({:error, result}) do
    IO.puts "\nParse error"
    IO.inspect result
  end

  def process_parse({:ok, tree}) do
    IO.puts "\nParse tree"
    IO.inspect tree, pretty: true
    state = Lunary.eval(tree, %{})
    IO.puts "\nFinal state"
    IO.inspect state, pretty: true
    state
  end
  
  def main(args) do
    filename = Enum.fetch!(args, 0)

    IO.puts "Parsing #{filename}"
    text = File.read!(filename)

    {:ok, tokens, line} = :lunary_lexer.string(String.to_charlist(text))
    IO.puts "Parsed #{filename}, stopped at line #{line}"
    IO.puts "\nTokens:"
    IO.inspect tokens, pretty: true

    result = process_parse(:lunary_parser.parse(tokens))
    result
  end

  def start_repl do
    IO.puts "welcome to lunary!"
    IO.puts "type 'exit' to quit"
    loop(%{})
  end

  defp loop(state) do
    IO.write("lun> ")
    input = IO.gets("") |> String.trim()

    case input do
      "exit" ->
        IO.puts("exiting...")
        :ok
      _ ->
        try do
          {result, scope} = eval(input, state, %{mode: :repl})
          IO.puts("> #{inspect(result)}")
          IO.inspect scope
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
         {:ok, tree} <- :lunary_parser.parse(tokens)
    do
      # IO.inspect tokens, pretty: true
      tree |> Lunary.eval(state, opts)
    else
      err -> err
    end
  end

  def test do
    IO.puts "testing..."
    p0 = "
      a = 100
      a
    "
    #p2 = "//(const:0)a=10\\>test(p1,p2)->(res=(p1+a-p2)res)val=/>test(9,2)+/>test(::const+1,1)"
    IO.inspect eval(p0)
  end
end

# todo: 
# - create repl interface
# - allow anonymous functions and assignment to an identifier that can be called
# - add | operator for function chaining
# - add ? and ! to valid identifier names
# - add support for string literals
