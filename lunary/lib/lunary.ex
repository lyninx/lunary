defmodule Lunary do
  # primitives
  # integer
  defp evaluate({:int, _line, value}, state, _opts), do: {value, state}
  # constant 
  defp evaluate({:const_ref, {:identifier, _line, identifier}}, state, _opts) do
    {Map.fetch!(state, "::#{identifier}"), state}
  end

  # maths
  defp evaluate({:add_op, lhs, rhs}, state, opts), do: math(:add_op, lhs, rhs, state, opts)
  defp evaluate({:sub_op, lhs, rhs}, state, opts), do: math(:sub_op, lhs, rhs, state, opts)
  defp evaluate({:mul_op, lhs, rhs}, state, opts), do: math(:mul_op, lhs, rhs, state, opts)
  defp evaluate({:div_op, lhs, rhs}, state, opts), do: math(:div_op, lhs, rhs, state, opts)

  defp math(operation, lhs, rhs, state, opts) do
    {lhs_v, _} = evaluate(lhs, state, opts)
    {rhs_v, _} = evaluate(rhs, state, opts)
    result = case operation do
      :add_op -> lhs_v + rhs_v
      :sub_op -> lhs_v - rhs_v
      :mul_op -> lhs_v * rhs_v
      :div_op -> lhs_v / rhs_v
    end
    {result, state}
  end

  # evaluate assignment

  defp evaluate([[{:assign, {:identifier, _line, lhs}, rhs}] | []], scope, opts) do
    {res, _} = evaluate(rhs, scope, opts)
    {res, Map.put(scope, lhs, res)}
  end

  defp evaluate([[{:assign, {:identifier, _line, lhs}, rhs}] | tail], scope, opts) do
    {rhs_value, _} = evaluate(rhs, scope, opts) # evaluate the right hand side
    updated_scope = Map.put(scope, lhs, rhs_value) # update scope to include new value
    evaluate(tail, updated_scope, opts)
  end

  defp evaluate([[[{:assign_const, {:identifier, _line, lhs}, rhs}]] | tail], scope, opts) do
    # assign constant to scope, error if it is already set
    lhs = "::#{lhs}"
    if Map.has_key?(scope, lhs) do
      raise "Constant #{lhs} is already defined"
    end
    {rhs_value, _} = evaluate(rhs, scope, opts)
    updated_scope = Map.put(scope, lhs, rhs_value)
    evaluate(tail, updated_scope, opts)
  end

  # evaluate function definition
  defp evaluate([[{:fdef, {:identifier, _line, name}, params, body}] | tail], scope, opts) do
    new_state = Map.put(scope, name, {params, body})
    evaluate(tail, new_state, opts)
  end

  # eval function call
  defp evaluate({:fcall, {:identifier, _line, name}, args}, scope, opts) do
    case Map.fetch(scope, name) do
      {:ok, {params, body}} ->
        arg_values = args 
          |> Enum.map(&evaluate(&1, scope, opts))
          |> Enum.map(fn {value, _} -> value end)
        param_names = Enum.map(params, fn {:identifier, _line, name} -> name end)
        new_scope = Enum.zip(param_names, arg_values) |> Enum.into(%{})
        merged_scope = Map.merge(scope, new_scope)
        evaluate(body, merged_scope, opts)
      :error ->
        raise "Function #{name} is not defined"
    end
  end

  # evaluate single identifier

  defp evaluate({:identifier, _line, identifier}, scope, opts) do
    {Map.get(scope, identifier), scope}
  end

  defp evaluate([tree], state, opts) do
    evaluate(tree, state, opts)
  end

  # evaluate dangling expression
  defp evaluate([[{op, lhs, rhs}] | tail], scope, opts) do
    {result, _} = evaluate({op, lhs, rhs}, scope, opts) 
    IO.puts "dangling expression eval: #{result}"
    evaluate(tail, scope, opts) # continue through the AST
  end
  
  def eval(tree, opts \\ %{}) do
    IO.inspect tree
    {result, scope} = evaluate(tree, %{}, opts)
    IO.inspect scope
    result
  end
end
