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
    state = Lunary.eval(tree)
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

  def parse_and_eval(string) do
    with {:ok, tokens, _line} <- String.to_char_list(string) |> :lunary_lexer.string(),
         {:ok, tree} <- :lunary_parser.parse(tokens)
    do
      IO.inspect tokens, pretty: true
      tree |> Lunary.eval
    else
      err -> err
    end
  end

  def test do
    IO.puts "testing..."
    program = "
      a = 7 
      \\> test (param, param2) -> ( res = param + 2 ) 
      b = 1 
      /> test (1, 2)
      c = 4
    "
    IO.inspect program
    # IO.inspect parse_and_eval("//( a: 7 b: 0 ) c = ::a  d = c * 2")
    IO.inspect parse_and_eval(program)
  end
end

## TODO: 
# - make function arguments get passed to the correct scope
# - default return value for functions
# - assign to variables from function calls
# - make constants accessible globally??
