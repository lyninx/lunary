defmodule Lunary do
  # primitives
  # integer
  defp evaluate({:int, _line, value}, scope, _opts), do: {value, scope}
  defp evaluate({:negate, expr}, scope, opts) do
    {value, _} = evaluate(expr, scope, opts)
    {-value, scope}
  end
  # constant 
  defp evaluate({:const_ref, {:identifier, _line, identifier}}, scope, _opts) do
    {Map.fetch!(scope, "::#{identifier}"), scope}
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

  defp evaluate({:assign_const, {:identifier, _line, lhs}, rhs}, scope, opts) do
    # assign constant to scope, error if it is already set
    lhs = "::#{lhs}"
    if Map.has_key?(scope, lhs) do
      raise "Constant #{lhs} is already defined"
    end
    {rhs_value, _} = evaluate(rhs, scope, opts)
    updated_scope = Map.put(scope, lhs, rhs_value)
    {rhs_value, updated_scope}
  end

  defp evaluate([[[{:assign_const, {:identifier, _line, _lhs}, _rhs} = current | []]] | []], scope, opts) do
    evaluate(current, scope, opts)
  end

  defp evaluate([[[{:assign_const, {:identifier, _line, _lhs}, _rhs} = current | []]] | tail], scope, opts) do
    {_, updated_scope} = evaluate(current, scope, opts)
    evaluate(tail, updated_scope, opts)
  end

  defp evaluate([[[{:assign_const, {:identifier, _line, _lhs}, _århs} = current | next]] | []], scope, opts) do
    with {_, updated_scope} <- evaluate(current, scope, opts),
         {last_const_val, updated_scope} <- evaluate(next, updated_scope, opts)
    do
      {last_const_val, updated_scope}
    end
  end
  
  defp evaluate([[[{:assign_const, {:identifier, _line, _lhs}, _rhs} = current | next]] | tail], scope, opts) do
    with {_, updated_scope} <- evaluate(current, scope, opts),
         {_, updated_scope} <- evaluate(next, updated_scope, opts)
    do
      evaluate(tail, updated_scope, opts)
    end
  end

  # evaluate function definition
  defp evaluate([[{:fdef, {:identifier, _line, name}, params, body}] | tail], scope, opts) do
    new_scope = Map.put(scope, name, {params, body})
    evaluate(tail, new_scope, opts)
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

  defp evaluate({:identifier, _line, identifier}, scope, _opts) do
    {Map.get(scope, identifier), scope}
  end

  defp evaluate([tree], scope, opts) do
    evaluate(tree, scope, opts)
  end

  # evaluate dangling expression
  defp evaluate([[{op, lhs, rhs}] | tail], scope, opts) do
    {_result, _} = evaluate({op, lhs, rhs}, scope, opts) 
    # IO.puts "dangling expression eval: #{result}"
    evaluate(tail, scope, opts) # continue through the AST
  end

  # maths
  defp evaluate({:add_op, lhs, rhs}, scope, opts), do: evaluate_math({:add, lhs, rhs}, scope, opts)
  defp evaluate({:sub_op, lhs, rhs}, scope, opts), do: evaluate_math({:sub, lhs, rhs}, scope, opts)
  defp evaluate({:mul_op, lhs, rhs}, scope, opts), do: evaluate_math({:mul, lhs, rhs}, scope, opts)
  defp evaluate({:div_op, lhs, rhs}, scope, opts), do: evaluate_math({:div, lhs, rhs}, scope, opts)

  defp evaluate_math({operation, lhs, rhs}, scope, opts) do
    {lhs_v, _} = evaluate(lhs, scope, opts)
    {rhs_v, _} = evaluate(rhs, scope, opts)
    result = case operation do
      :add -> lhs_v + rhs_v
      :sub -> lhs_v - rhs_v
      :mul -> lhs_v * rhs_v
      :div -> lhs_v / rhs_v
    end
    {result, scope}
  end
  
  def eval(tree, init_state, opts \\ %{}) do
    {result, scope} = evaluate(tree, init_state, opts)
    if opts[:debug] && opts[:print_scope], do: IO.inspect scope
    case opts do
      %{mode: :repl} -> {result, scope}
      _ -> result
    end
  end
end
