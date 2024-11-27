defmodule Lunary do
  # primitives
  # integer
  defp evaluate({:int, _line, value}, scope, _opts), do: {value, scope}

  defp evaluate({:negate, expr}, scope, opts) do
    {value, _} = evaluate(expr, scope, opts)
    {-value, scope}
  end

  # string
  defp evaluate({:string, _line, value}, scope, _opts), do:  {value, scope}

  # array
  defp evaluate({:array, array}, scope, opts) do
    computed_array = Enum.map(array, fn elem -> 
      {res, _} = evaluate(elem, scope, opts) 
      res 
    end)
    {computed_array, scope}
  end

  # constant 
  defp evaluate({:const_ref, {:identifier, _line, identifier}}, scope, opts) do
    # todo: handle not found
    const = case Map.fetch(scope, "::#{identifier}") do
      :error -> raise "Constant ::#{identifier} is not defined"
      {:ok, value} -> value
    end
    {res, _} = evaluate(const, scope, opts)
    {res, scope}
  end

  # module 
  defp evaluate({:mod_ref, {_, _line, uri}}, _scope, opts) do
    # read file with name identifier.lun
    filepath = opts[:path] || ""
    filename = String.downcase("#{uri}.lun")
    fullpath = Path.join(filepath, filename)
    case File.read(fullpath) do
      {:ok, content} ->
        {:ok, tokens, _line} = :lunary_lexer.string(String.to_charlist(content))
        {:ok, tree} = :lunary_parser.parse(tokens)
        evaluate(tree, %{}, %{})
      {:error, _} -> raise "Module #{uri} (#{fullpath}) not found"
    end
  end

  # evaluate assignment

  defp evaluate([[{:assign, {:identifier, _line, lhs}, rhs}] | []], scope, opts) do
    {res, _} = evaluate(rhs, scope, opts)
    {res, Map.put(scope, lhs, res)}
  end

  defp evaluate([[{:assign, {:identifier, _line, lhs}, rhs}] | tail], scope, opts) do
    # evaluate the right hand side
    {rhs_value, _} = evaluate(rhs, scope, opts)
    # update scope to include new value
    updated_scope = Map.put(scope, lhs, rhs_value)
    evaluate(tail, updated_scope, opts)
  end

  # TODO: can these be collapsed into the assign functions above? parser needs to be updated to support this.
  defp evaluate([[{:fassign, {:identifier, _line, lhs}, rhs}] | []], scope, opts) do
    {res, _} = evaluate(rhs, scope, opts)
    {res, Map.put(scope, lhs, res)}
  end

  defp evaluate([[{:fassign, {:identifier, _line, lhs}, rhs}] | tail], scope, opts) do
    # evaluate the right hand side
    {rhs_value, _} = evaluate(rhs, scope, opts)
    # update scope to include new value
    updated_scope = Map.put(scope, lhs, rhs_value)
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

  defp evaluate([[[{:assign_const, _, _rhs} = current | []]] | []], scope, opts) do
    evaluate(current, scope, opts)
  end

  defp evaluate([[[{:assign_const, _, _rhs} = current | []]] | tail], scope, opts) do
    {_, updated_scope} = evaluate(current, scope, opts)
    evaluate(tail, updated_scope, opts)
  end

  defp evaluate([[[{:assign_const, _, _rhs} = current | next]] | []], scope, opts) do
    with {_, updated_scope} <- evaluate(current, scope, opts),
         {last_const_val, updated_scope} <- evaluate(next, updated_scope, opts) do
      {last_const_val, updated_scope}
    end
  end

  defp evaluate([[[{:assign_const, _, _rhs} = current | next]] | tail], scope, opts) do
    with {_, updated_scope} <- evaluate(current, scope, opts),
         {_, updated_scope} <- evaluate(next, updated_scope, opts) do
      evaluate(tail, updated_scope, opts)
    end
  end

  # evaluate function definition
  defp evaluate([[{:fdef, {:identifier, line, name}, params, body}] | []], scope, _opts) do
    func = {:fn, {:identifier, line, name}, params, body}
    new_scope = Map.put(scope, name, func)
    {func, new_scope}
  end

  defp evaluate([[{:fdef, {:identifier, line, name}, params, body}] | tail], scope, opts) do
    func = {:fn, {:identifier, line, name}, params, body}
    new_scope = Map.put(scope, name, func)
    evaluate(tail, new_scope, opts)
  end

  # evaluate anon function definition
  defp evaluate({:anon_fdef, params, body}, scope, _opts) do
    func = {:fn, params, body}
    {func, scope}
  end

  # eval function call
  defp evaluate({:fn, {:identifier, _line, name}, args}, scope, opts) do
    case Map.fetch(scope, name) do
      {:ok, {:fn, _, params, body}} -> evaluate_function({:fn, params, body}, args, scope, opts)
      {:ok, {:fn, params, body}} -> evaluate_function({:fn, params, body}, args, scope, opts)
      :error ->
        raise "Function #{name} is not defined"
    end
  end

  defp evaluate({:const_fn, {:identifier, _line, name}, args}, scope, opts) do
    case Map.fetch(scope, "::#{name}") do
      {:ok, {:fn, _, params, body}} -> evaluate_function({:fn, params, body}, args, scope, opts)
      {:ok, {:fn, params, body}} -> evaluate_function({:fn, params, body}, args, scope, opts)
      :error ->
        IO.inspect(scope)
        raise "Function #{name} is not defined"
    end
  end

  # evaluate nil
  defp evaluate({:nil}, scope, _opts) do
    {nil, scope}
  end

  # evaluate single identifier

  defp evaluate({:identifier, _line, identifier}, scope, opts) do
    lookup = Map.get(scope, identifier)
    evaluate(lookup, scope, opts)
  end

  # dig through the AST
  defp evaluate([tree], scope, opts) when is_list(tree) and length(tree) > 0, do: evaluate(tree, scope, opts)
  defp evaluate([tree], scope, opts) when is_tuple(tree), do: evaluate(tree, scope, opts)

  # evaluate dangling expression
  defp evaluate([[{op, lhs, rhs}] | tail], scope, opts) do
    {_result, _} = evaluate({op, lhs, rhs}, scope, opts)
    # continue through the AST
    evaluate(tail, scope, opts)
  end

  # maths
  defp evaluate({:add_op, lhs, rhs}, scope, opts),
    do: evaluate_math({:add, lhs, rhs}, scope, opts)

  defp evaluate({:sub_op, lhs, rhs}, scope, opts),
    do: evaluate_math({:sub, lhs, rhs}, scope, opts)

  defp evaluate({:mul_op, lhs, rhs}, scope, opts),
    do: evaluate_math({:mul, lhs, rhs}, scope, opts)

  defp evaluate({:div_op, lhs, rhs}, scope, opts),
    do: evaluate_math({:div, lhs, rhs}, scope, opts)

  # evaluate raw value
  defp evaluate(value, scope, _opts) do
    {value, scope}
  end

  defp evaluate_math({operation, lhs, rhs}, scope, opts) do
    {lhs_v, _} = evaluate(lhs, scope, opts)
    {rhs_v, _} = evaluate(rhs, scope, opts)

    result =
      case operation do
        :add -> lhs_v + rhs_v
        :sub -> lhs_v - rhs_v
        :mul -> lhs_v * rhs_v
        :div -> lhs_v / rhs_v
      end

    {result, scope}
  end

  defp evaluate_function({:fn, params, body}, args, scope, opts) do
    arg_values =
      args
      |> Enum.map(&evaluate(&1, scope, opts))
      |> Enum.map(fn {value, _} -> value end)

    param_names = Enum.map(params, fn {:identifier, _line, name} -> name end)
    new_scope = Enum.zip(param_names, arg_values) |> Enum.into(%{})
    merged_scope = Map.merge(scope, new_scope)
    evaluate(body, merged_scope, opts)
  end

  def eval(tree, init_state, opts \\ %{}) do
    {result, scope} = evaluate(tree, init_state, opts)
    if opts[:debug] && opts[:print_scope], do: IO.inspect(scope)

    case opts do
      %{mode: :repl} -> {result, scope}
      _ -> result
    end
  end
end
