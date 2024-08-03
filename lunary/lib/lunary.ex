defmodule Lunary do
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

  defp reduce_to_value({:reference, {:identifier, _line, identifier}}, state) do
    state[identifier]
  end

  defp reduce_to_value({:identifier, _line, identifier}, state) do
    state[identifier]
  end
  
  # tree evaluation

  # evaluate assignment
  defp evaluate_tree([{:assign, {:identifier, _line, lhs}, rhs} | tail], state) do
    rhs_value = reduce_to_value(rhs, state)
    evaluate_tree(tail, Map.put(state, lhs, rhs_value))
  end

  # evaluate next AST node
  defp evaluate_tree([head | tail], state) when is_list(head) do
    new_state = Enum.reduce(head, state, &evaluate_tree([&1], &2))
    evaluate_tree(tail, new_state)
  end  
  
  # return state
  defp evaluate_tree([], state) do
    state
  end
  
  def eval(tree) do
    evaluate_tree(tree, %{})
  end
end