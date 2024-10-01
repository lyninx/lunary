defmodule Lunary do
  # primitives
  # integer
  defp evaluate_tree({:int, _line, value}, _state, _opts), do: value
  # constant 
  defp evaluate_tree({:const_ref, {:identifier, _line, identifier}}, state, _opts) do
    Map.fetch!(state, "::#{identifier}")
  end

  # maths
  # addition
  defp evaluate_tree({:add_op, lhs, rhs}, state, opts) do
    evaluate_tree(lhs, state, opts) + evaluate_tree(rhs, state, opts)
  end
  # subtraction
  defp evaluate_tree({:sub_op, lhs, rhs}, state, opts) do
    evaluate_tree(lhs, state, opts) - evaluate_tree(rhs, state, opts)
  end
  # multiplication
  defp evaluate_tree({:mul_op, lhs, rhs}, state, opts) do
    evaluate_tree(lhs, state, opts) * evaluate_tree(rhs, state, opts)
  end
  # division
  defp evaluate_tree({:div_op, lhs, rhs}, state, opts) do
    evaluate_tree(lhs, state, opts) / evaluate_tree(rhs, state, opts)
  end

  # evaluate assignment

  defp evaluate_tree([[{:assign, {:identifier, _line, lhs}, rhs}] | []], scope, opts) do
    evaluate_tree(rhs, scope, opts)
  end

  defp evaluate_tree([[{:assign, {:identifier, _line, lhs}, rhs}] | tail], scope, opts) do
    rhs_value = evaluate_tree(rhs, scope, opts)
    evaluate_tree(tail, Map.put(scope, lhs, rhs_value), opts)
  end

  defp evaluate_tree([[[{:assign_const, {:identifier, _line, lhs}, rhs}]] | tail], scope, opts) do
    # assign constant to scope, error if it is already set
    lhs = "::#{lhs}"
    if Map.has_key?(scope, lhs) do
      raise "Constant #{lhs} is already defined"
    end
    rhs_value = evaluate_tree(rhs, scope, opts)
    evaluate_tree(tail, Map.put(scope, lhs, rhs_value), opts)
  end

  # evaluate function definition
  defp evaluate_tree([[{:fdef, {:identifier, _line, name}, params, body}] | tail], scope, opts) do
    new_state = Map.put(scope, name, {params, body})
    evaluate_tree(tail, new_state, opts)
  end

  # eval function call
  defp evaluate_tree({:fcall, {:identifier, _line, name}, args}, scope, opts) do
    case Map.fetch(scope, name) do
      {:ok, {params, body}} ->
        arg_values = Enum.map(args, &evaluate_tree(&1, scope, opts))
        param_names = Enum.map(params, fn {:identifier, _line, name} -> name end)
        new_scope = Enum.zip(param_names, arg_values) |> Enum.into(%{})
        merged_scope = Map.merge(scope, new_scope)
        evaluate_tree(body, merged_scope, opts)
      :error ->
        raise "Function #{name} is not defined"
    end
  end

  # evaluate single identifier

  defp evaluate_tree({:identifier, _line, identifier}, scope, opts) do
    Map.get(scope, identifier)
  end

  defp evaluate_tree([tree], state, opts) do
    evaluate_tree(tree, state, opts)
  end

  # evaluate dangling expression
  defp evaluate_tree([[{op, lhs, rhs}] | tail], scope, opts) do
    result = evaluate_tree({op, lhs, rhs}, scope, opts) 
    IO.puts "dangling expression eval: #{result}"
    evaluate_tree(tail, scope, opts) # continue through the AST
  end
  
  def eval(tree, opts \\ %{}) do
    evaluate_tree(tree, %{}, opts)
  end
end
