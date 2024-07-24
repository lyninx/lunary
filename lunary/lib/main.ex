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
    state = LunaryParser.process_tree(tree)
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

  def parse(text) do
    {:ok, tokens, _line} = :lunary_lexer.string(String.to_charlist(text))
    {:ok, tree} = :lunary_parser.parse(tokens)
    LunaryParser.process_tree(tree)
  end

  def test do
    IO.puts "testing..."
    IO.inspect parse("a = 7\n b = 4\n result = a + b")
  end
end
