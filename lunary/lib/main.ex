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
      a = 100
      \\> test (p, p2) -> ( 
        p + p2
      )
      /> test (10, 20)
      b = 0
    "
    p1 = "
      //( const: 0 )
      a = 10 
      \\> test (param, param2) -> ( 
        res = (param + a - param2)
        res  
      ) 
      b = 1 
      val = /> test (9, 2)
      val2 = /> test (2, 2)
      c = ::const
      d = 0
    "
    p2 = "//(const:0)a=10\\>test(p1,p2)->(res=(p1+a-p2)res)val=/>test(9,2)+/>test(::const+1,1)"
    IO.inspect program
    IO.inspect parse_and_eval(program)
  end
end

# todo: 
# - make sure default funciton returns are consistent
# - add | operator for function chaining
# - add ? and ! to valid identifier names

