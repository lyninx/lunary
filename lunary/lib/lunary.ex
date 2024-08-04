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
    Map.fetch!(state, "::#{identifier}")
  end

  defp reduce_to_value({:fcall, {:identifier, _line, name}, args}, scope) do
    case Map.fetch(scope, name) do
      {:ok, {params, body}} ->
        arg_values = Enum.map(args, &reduce_to_value(&1, scope))
        param_names = Enum.map(params, fn {:identifier, _line, name} -> name end)
        new_scope = Enum.zip(param_names, arg_values) |> Enum.into(%{})
        merged_scope = Map.merge(scope, new_scope)
        evaluate_tree(body, [merged_scope])
      :error ->
        raise "Function #{name} is not defined"
    end
  end

  defp reduce_to_value({:identifier, _line, identifier}, state) do
    Map.fetch!(state, identifier)
  end

  # # evaluate function call
  # defp reduce_to_value({:fcall, name, args}, state) do
  #   {params, body} = state[name]
  #   new_scope = Enum.zip(params, args) |> Enum.into(%{})
  #   evaluate_tree(body, [new_scope | state])
  # end
  
  # tree evaluation

  # evaluate assignment
  defp evaluate_tree([{:assign, {:identifier, _line, lhs}, rhs} | tail], [scope | rest]) do
    # IO.puts ":assign"
    # IO.inspect rhs
    rhs_value = reduce_to_value(rhs, scope)
    evaluate_tree(tail, [Map.put(scope, lhs, rhs_value) | rest])
  end

  defp evaluate_tree([{:assign_const, {:identifier, _line, lhs}, rhs} | tail], [scope | rest]) do
    # assign constant to scope, error if it is already set
    lhs = "::#{lhs}"
    if Map.has_key?(scope, lhs) do
      raise "Constant #{lhs} is already defined"
    end
    rhs_value = reduce_to_value(rhs, scope)
    evaluate_tree(tail, [Map.put(scope, lhs, rhs_value) | rest])
  end

  # evaluate function call
  defp evaluate_tree([{:fcall, {:identifier, _line, name}, args} | tail], [scope | rest]) do
    # IO.puts ":fcall"
    # IO.inspect scope
    case Map.fetch(scope, name) do
      {:ok, {params, body}} ->
        arg_values = Enum.map(args, &reduce_to_value(&1, scope))
        param_names = Enum.map(params, fn {:identifier, _line, name} -> name end)
        new_scope = Enum.zip(param_names, arg_values) |> Enum.into(%{})
        merged_scope = Map.merge(scope, new_scope)
        result = evaluate_tree(body, [merged_scope | rest])# |> List.first()
        evaluate_tree(tail, [Map.put(scope, "!!", result) | rest])
      :error ->
        raise "Function #{name} is not defined"
    end
  end

  # evaluate function definition
  defp evaluate_tree([{:fdef, {:identifier, _line, name}, params, body} | tail], [scope | rest]) do
    new_state = [Map.put(scope, name, {params, body}) | rest]
    evaluate_tree(tail, new_state)
  end

  # evaluate next AST node
  defp evaluate_tree([head | tail], state) when is_list(head) do
    new_state = Enum.reduce(head, state, fn x, scope ->
      evaluate_tree([x], scope)
    end)
    evaluate_tree(tail, new_state)
  end  

  # evaluate single identifier
  defp evaluate_tree([{:identifier, _line, identifier} | tail], [scope | rest]) do
    Map.get(scope, identifier)
  end

  # return state
  defp evaluate_tree([], state) do
    state
  end

  # default eval, attempt to reduce to value
  defp evaluate_tree([head | tail], [scope | rest]) do
    IO.inspect head
    value = reduce_to_value(head, scope)
    # res = Map.merge(scope, %{"!!" => value})
    # IO.inspect res
    # res
    value
  end
  
  def eval(tree) do
    evaluate_tree(tree, [%{}])
  end
end