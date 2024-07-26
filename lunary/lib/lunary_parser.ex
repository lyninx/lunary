defmodule LunaryParser do
  # reduction logic
  defp reduce_to_value({:int, _line, value}, _state) do
    value
  end

  defp reduce_to_value({:add_op, lhs, rhs}, state) do
    reduce_to_value(lhs, state) + reduce_to_value(rhs, state)
  end

  defp reduce_to_value({:sub_op, lhs, rhs}, state) do
    reduce_to_value(lhs, state) - reduce_to_value(rhs, state)
  end

  defp reduce_to_value({:mul_op, lhs, rhs}, state) do
    reduce_to_value(lhs, state) * reduce_to_value(rhs, state)
  end

  defp reduce_to_value({:div_op, lhs, rhs}, state) do
    reduce_to_value(lhs, state) / reduce_to_value(rhs, state)
  end

  defp reduce_to_value({:identifier, _line, identifier}, state) do
    state[identifier]
  end
  
  # eval logic
  defp evaluate_tree([{:assign, {:identifier, _line, lhs}, rhs} | tail], state) do
    rhs_value = reduce_to_value(rhs, state)
    evaluate_tree(tail, Map.put(state, lhs, rhs_value))
  end

  defp evaluate_tree([{:reference, {:identifier, _line, identifier}} | tail], state) do
    case Map.fetch(state, identifier) do
      {:ok, value} -> evaluate_tree(tail, Map.put(state, identifier, value))
      :error -> raise "Undefined variable #{identifier}"
    end
  end

  defp evaluate_tree([], state) do
    state
  end

  def process_tree(tree) do
    evaluate_tree(tree, %{})
  end

  def parse_and_eval(string) do
    {:ok, tokens, _line} = :lunary_lexer.string(String.to_char_list(string))
    {:ok, tree} = :lunary_parser.parse(tokens)
    process_tree(tree)
  end
end