defmodule Lunary do
  # reduction logic
  defp evaluate_tree({:int, _line, value}, _state) do
    value
  end

  # ADD
  defp evaluate_tree({:add_op, lhs, rhs}, [state]) do
    evaluate_tree(lhs, [state]) + evaluate_tree(rhs, [state])
  end

  # SUBTRACT
  defp evaluate_tree({:sub_op, lhs, rhs}, [state]) do
    evaluate_tree(lhs, [state]) - evaluate_tree(rhs, [state])
  end

  # MULTIPLY
  defp evaluate_tree({:mul_op, lhs, rhs}, [state]) do
    evaluate_tree(lhs, [state]) * evaluate_tree(rhs, [state])
  end

  # DIVIDE
  defp evaluate_tree({:div_op, lhs, rhs}, [state]) do
    evaluate_tree(lhs, [state]) / evaluate_tree(rhs, [state])
  end

  # CONST REF 
  defp evaluate_tree({:const_ref, {:identifier, _line, identifier}}, [state]) do
    Map.fetch!(state, "::#{identifier}")
  end

  # function call
  defp reduce_to_value({:fcall, {:identifier, _line, name}, args}, scope) do
    case Map.fetch(scope, name) do
      {:ok, {params, body}} ->
        arg_values = Enum.map(args, &evaluate_tree(&1, [scope]))
        param_names = Enum.map(params, fn {:identifier, _line, name} -> name end)
        new_scope = Enum.zip(param_names, arg_values) |> Enum.into(%{})
        merged_scope = Map.merge(scope, new_scope)
        result = evaluate_tree(body, [merged_scope])
        # IO.puts "result: #{result}"
        result
      :error ->
        raise "Function #{name} is not defined"
    end
  end
  
  # tree evaluation

  # evaluate assignment

  defp evaluate_tree([[{:assign, {:identifier, _line, lhs}, rhs}] | []], [scope | rest]) do
    IO.puts ":assign"
    evaluate_tree(rhs, [scope])
  end

  defp evaluate_tree([[{:assign, {:identifier, _line, lhs}, rhs}] | tail], [scope | rest]) do
    IO.puts ":assign"
    IO.inspect tail

    rhs_value = evaluate_tree(rhs, [scope])
    evaluate_tree(tail, [Map.put(scope, lhs, rhs_value) | rest])
  end

  defp evaluate_tree([[[{:assign_const, {:identifier, _line, lhs}, rhs}]] | tail], [scope | rest]) do
    # assign constant to scope, error if it is already set
    lhs = "::#{lhs}"
    if Map.has_key?(scope, lhs) do
      raise "Constant #{lhs} is already defined"
    end
    rhs_value = evaluate_tree(rhs, [scope])
    evaluate_tree(tail, [Map.put(scope, lhs, rhs_value) | rest])
  end

  # evaluate single function call
  defp evaluate_tree({:fcall, {:identifier, _line, name}, args}, [scope | rest]) do
    result = reduce_to_value({:fcall, {:identifier, _line, name}, args}, scope)
    IO.puts "eval_tree_fcall_final: #{result}"
    result
  end

  # evaluate function call chain
  # defp evaluate_tree([[{:fcall, {:identifier, _line, name}, args}] | tail], [scope | rest]) do
  #   result = reduce_to_value({:fcall, {:identifier, _line, name}, args}, scope)
  #   IO.puts "eval_tree_fcall: #{result}"
  #   evaluate_tree(tail, [Map.put(scope, "!!", result) | rest])
  # end

  # evaluate function definition
  defp evaluate_tree([[{:fdef, {:identifier, _line, name}, params, body}] | tail], [scope | rest]) do
    new_state = [Map.put(scope, name, {params, body}) | rest]
    evaluate_tree(tail, new_state)
  end

  # evaluate single identifier
  defp evaluate_tree({:identifier, _line, identifier}, [scope | rest]) do
    Map.get(scope, identifier)
  end

  defp evaluate_tree([tree], state) do
    evaluate_tree(tree, state)
  end

  # evaluate dangling expression
  defp evaluate_tree([[{op, lhs, rhs}] | tail], [state]) do
    result = evaluate_tree({op, lhs, rhs}, [state]) 
    IO.puts "dangling experssion eval: #{result}"
    evaluate_tree(tail, [state]) # continue through the AST
  end

  # return state
  defp evaluate_tree([], state) do
    IO.puts "state"
    IO.inspect state
    state
  end
  
  def eval(tree) do
    evaluate_tree(tree, [%{}])
  end
end