defmodule Lunary do
  require IEx
  defmodule ParseError do
    defexception message: "a parsing error occurred"
    def exception(reason) do
      %ParseError{message: reason}
    end
  end
  # primitives
  # integer
  defp evaluate({:int, _line, value}, scope, _opts), do: {value, scope}

  defp evaluate({:negate, expr}, scope, opts) do
    {value, _} = evaluate(expr, scope, opts)
    {-value, scope}
  end

  # string
  defp evaluate({:string, _line, value}, scope, _opts) do
    {value, scope}
  end

  defp evaluate({:template_string, _line, parts}, scope, opts) do
    result = parts
    |> Enum.map(fn
      {:string, _, value} -> value
      {:string_interp, _line, val} ->
        with {:ok, tokens, _} <- :lunary_lexer.string(String.to_charlist("(#{val})")),
          {:ok, ast} <- :lunary_parser.parse(tokens),
          {value, _scope} <- evaluate(ast, scope, opts)
        do
          value
        end
    end)
    |> Enum.join("")

    {result, scope}
  end

  # comment
  defp evaluate({:comment, _line, _comment}, scope, _opts), do: {nil, scope}

  # map
  defp evaluate({:map, map}, scope, _opts) when is_map(map), do: {map, scope}
  defp evaluate({:map, pairs}, scope, opts) do
    # todo: add support for more expression types
    map = Enum.reduce(pairs, %{}, fn [key | value], acc ->
      converted_key = case key do
        {:identifier, _, key} -> String.to_atom(key)
        {:map, _} ->
          {evaluated_map, _} = evaluate(key, scope, opts)
          evaluated_map
        {:list, _} ->
          {evaluated_list, _} = evaluate(key, scope, opts)
          evaluated_list
        {:string, _, key} -> key
      end
      {key_v, _} = evaluate(converted_key, scope, opts)
      {value_v, _} = evaluate(value, scope, opts)
      Map.put(acc, key_v, value_v)
    end)

    {map, scope}
  end

  # array
  defp evaluate({:list, list}, scope, opts) do
    computed_list = Enum.map(list, fn elem ->
      {res, _} = evaluate(elem, scope, opts)
      res
    end)
    {computed_list, scope}
  end

  defp evaluate({:range, start, stop}, scope, opts) do
    {start_v, _} = evaluate(start, scope, opts)
    {stop_v, _} = evaluate(stop, scope, opts)
    {Enum.to_list(start_v..stop_v), scope}
  end

  defp evaluate({:access, {:string, _line, string}, index}, scope, opts) do
    value = case evaluate(index, scope, opts) do
      {i, _} when is_list(i) ->
        i
        |> Enum.map(fn i -> String.at(string, i) end)
        |> Enum.join("")
      {i, _} -> string |> String.at(i)
    end
    {value, scope}
  end

  defp evaluate({:access, {:access, _rest, _inner_index} = inner_access, index}, scope, opts) do
    {result, _} = evaluate(inner_access, scope, opts)
    case result do
      map when is_map(map) ->
        evaluate({:access, {:map, map}, index}, scope, opts)
      list when is_list(list) ->
        evaluate({:access, {:list, list}, index}, scope, opts)
    end
  end

  defp evaluate({:access, {:identifier, _, _enum} = identifier, {:identifier, _line, index}}, scope, opts) do
    evaluate({:access, identifier, index}, scope, opts)
  end

  # defp evaluate({:access, {:identifier, _, _enum} = identifier, {:identifier, line, index}}, scope, opts) when is_integer(index) do
  #   evaluate({:access, identifier, {:int, line, index}}, scope, opts)
  # end

  # defp evaluate({:access, {:identifier, _, _enum} = identifier, {:identifier, line, index}}, scope, opts) do
  #   evaluate({:access, identifier, {:atom, line, String.to_atom(index)}}, scope, opts)
  # end


  defp evaluate({:atom_access, {_, _rest, _inner_index} = inner_access, {:identifier, line, index}}, scope, opts) do
    index = {:atom, line, String.to_atom(index)}
    {result, _} = evaluate(inner_access, scope, opts)
    case result do
      map when is_map(map) ->
        evaluate({:access, {:map, map}, index}, scope, opts)
      list when is_list(list) ->
        evaluate({:access, {:list, list}, index}, scope, opts)
    end
  end

  defp evaluate({:atom_access, {:identifier, _, _enum} = identifier, {:identifier, line, index}}, scope, opts) do
    index = {:atom, line, String.to_atom(index)}
    evaluate({:access, identifier, index}, scope, opts)
  end

  defp evaluate({:func_access, index, {:fn, {:identifier, fn_line, fn_id}, fn_args}}, scope, opts) do
    {func_scope, _} = evaluate(index, scope, opts)
    merged_scope = Map.merge(func_scope, scope)
    evaluate({:fn, {:identifier, fn_line, fn_id}, fn_args}, merged_scope, opts)
  end

  defp evaluate({:access, {:map, _map} = enum, index}, scope, opts) do
    {map, _} = evaluate(enum, scope, opts)
    evaluated_index = case index do
      idx when is_binary(idx) ->
        evaluate({:identifier, nil, idx}, scope, opts)
      idx ->
        evaluate(idx, scope, opts)
    end

    value = case evaluated_index do
      {k, _} when is_list(k) ->
        k |> Enum.map(fn k -> Map.get(map, k) end)
      {k, _} ->
        Map.get(map, k)
      other when is_tuple(other) ->
        {result, _scope} = evaluate(other, scope, opts)
        result
    end
    {value, scope}
  end

  defp evaluate({:access, {:list, _arr} = enum, index}, scope, opts) do
    {list, _} = evaluate(enum, scope, opts)
    value = case evaluate(index, scope, opts) do
      {i, _} when is_list(i) ->
        i |> Enum.map(fn i -> Enum.at(list, i) end)
      {i, _} -> list |> Enum.at(i)
    end
    {value, scope}
  end

  defp evaluate({:access, {:fn, {:identifier, _line, _id} = identifier, args}, index}, scope, opts) do
    identified_enum = case evaluate({:fn, identifier, args}, scope, opts) do
      {enum, _} when is_map(enum) -> {:access, {:map, enum}, index}
      {enum, _} when is_list(enum) -> {:access, {:list, enum}, index}
    end
    evaluate(identified_enum, scope, opts)
  end

  defp evaluate({:access, {:module_ref, {:identifier, _line, _id}} = module_ref, index}, scope, opts) do
    identified_enum = case evaluate(module_ref, scope, opts) do
      {enum, _} when is_map(enum) -> {:access, {:map, enum}, index}
      {enum, _} when is_list(enum) -> {:access, {:list, enum}, index}
      # todo: need a case for no match?
    end
    evaluate(identified_enum, scope, opts)
  end

  defp evaluate({:access, {:module, _, module_scope}, index}, _scope, opts) do
    identified_enum = case module_scope do
      {enum, _} when is_map(enum) -> {:access, {:map, enum}, index}
      {enum, _} when is_list(enum) -> {:access, {:list, enum}, index}
      enum when is_map(enum) -> {:access, {:map, enum}, index}
      enum when is_list(enum) -> {:access, {:list, enum}, index}
      # todo: need a case for no match?
    end
    evaluate(identified_enum, module_scope, opts)
  end

  defp evaluate({:access, enum, index}, scope, opts) do # catchall for access
    identified_enum = case evaluate(enum, scope, opts) do
      {enum, _} when is_map(enum) ->
        {:access, {:map, enum}, index}
      {enum, _} when is_list(enum) -> {:access, {:list, enum}, index}
      {enum, _} ->
        {:access, enum, index}
    end
    evaluate(identified_enum, scope, opts)
  end

defp evaluate({:concat, left, right}, scope, opts) do
  {left_v, _} = evaluate(left, scope, opts)
  {right_v, _} = evaluate(right, scope, opts)

  result = case {left_v, right_v} do
    {l, r} when is_binary(l) and is_binary(r) ->
      l <> r

    {l, r} when is_list(l) and is_list(r) ->
      l ++ r

    {l, r} when is_map(l) and is_map(r) ->
      Map.merge(l, r)

    _ ->
      raise "Cannot concatenate #{inspect(left_v)} and #{inspect(right_v)}"
  end

  {result, scope}
end

  # atom
  defp evaluate({:atom, _line, atom}, scope, _opts), do: {atom, scope}

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
  # module eval

  defp evaluate({:module, {:identifier, _line, module_id}, module_source}, scope, opts) do
    # validate module name?
    if String.starts_with?(module_id, "@") do
      {module_value, _module_scope} = evaluate(module_source, scope, opts)
      {module_value, Map.put(scope, module_id, module_value)}
    else
      raise "Module identifier must begin with @"
    end
  end

  # module definition
  defp evaluate({:moddef, {:identifier, _line, module_id} = identifier, body}, scope, opts) do
    {_, module_scope} = evaluate(body, %{}, opts)
    module = module_scope
      |> Enum.map(fn {key, value} -> {key, value} end)
      |> Enum.into(%{})
    new_scope = Map.put(scope, module_id, {:module, identifier, module})
    {new_scope, new_scope}
  end

  # module autoload

  # defp evaluate([[module = {:module_load, _, _}] | tail], scope, opts) do
  #   {module_value, new_scope} = evaluate(module, scope, opts)
  # end

  defp evaluate({:module_load, {:identifier, line, module_id}}, scope, opts) do
    module_name = String.trim_leading(module_id, "@")
    {result, _scope} = evaluate({:import, {:uri, line, module_name}}, scope, opts)
    new_scope = Map.put(scope, module_id, result)
    {result, new_scope}
  end
  # module include (old)
  # defp evaluate([[module = {:module, _, _}] | tail], scope, opts) do
  #   {module_value, new_scope} = evaluate_module(module, scope, opts)
  #   case tail do
  #     [] -> {module_value, new_scope}
  #     _ -> evaluate(tail, new_scope, opts)
  #   end
  # end

  # import
  defp evaluate({:import, {_, _line, uri}}, _scope, opts) do
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

  defp evaluate({:assign, {:identifier, _line, lhs}, rhs}, scope, opts) do
    {rhs_value, _} = evaluate(rhs, scope, opts)
    updated_scope = Map.put(scope, lhs, rhs_value)
    {rhs_value, updated_scope}
  end

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

  defp evaluate({:assign_enum, {:access, enum, index}, rhs}, scope, opts) do
    {enum_v, _} = evaluate(enum, scope, opts)
    {index_v, _} = evaluate(index, scope, opts)
    {rhs_v, _} = evaluate(rhs, scope, opts)
    updated_enum = case enum_v do
      map when is_map(map) ->
        case index_v do
          k when is_list(k) ->
            Enum.reduce(k, map, fn k, acc -> Map.put(acc, k, rhs_v) end)
          k -> Map.put(map, k, rhs_v)
        end
      list when is_list(list) ->
        case index_v do
          i when is_list(i) ->
            Enum.reduce(i, list, fn i, acc -> List.replace_at(acc, i, rhs_v) end)
          i -> List.replace_at(list, i, rhs_v)
        end
      other ->
        raise "Cannot assign to non-enum type: #{inspect(other)}"
    end
    {updated_enum, scope}
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

  defp evaluate({:const_block, map}, scope, opts) do
    updated_scope = Enum.reduce(map, scope, fn [key, value], acc_scope ->
      {_value, new_scope} = evaluate({:assign_const, key, value}, acc_scope, opts)
      new_scope
    end)
    {updated_scope, updated_scope}
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

  # function chaining
  defp evaluate({:chain, lhs, rhs}, scope, opts) do
    {lhs_v, _} = case lhs do
      {:chain, _, _} ->
        evaluate(lhs, scope, opts)
      other ->
        evaluate(other, scope, opts)
    end
    {rhs_v, _} = case rhs do
      {:fn, fn_identifier, args} ->
        evaluate({:fn, fn_identifier, [lhs_v | args]}, scope, opts)
      {:identifier, _line, _fn_name} = identifier ->
        evaluate({:fn, identifier, [lhs_v]}, scope, opts)
      {:func_access, module_id, {:fn, func_id, func_args}} ->
        # TODO: this is duplicated from :func_access, should be generalized
        # also, need a more elegant way to convert string function ids to atoms
        {func_scope, _} = evaluate(module_id, scope, opts)
        merged_scope = Map.merge(func_scope, scope) # is this overly broad?
        {:identifier, fn_line, fn_name} = func_id
        evaluate({:fn, {:identifier, fn_line, fn_name}, [lhs_v | func_args]}, merged_scope, opts)
      {:atom_access, identifier, index} ->
        case evaluate({:access, identifier, index}, scope, opts) do
          {{:fn, _identifier, params, body}, scope} ->
            evaluate_function({:fn, params, body}, [lhs_v], scope, opts)
          _ ->
            raise "Chained access did not return a function"
        end
      other ->
        evaluate(other, scope, opts)
    end
    {rhs_v, scope}
  end

  # eval function call
  defp evaluate({:fn, {:identifier, _line, name}, args}, scope, opts) do
    case Map.fetch(scope, name) do
      {:ok, {:fn, _, params, body}} ->
        evaluate_function({:fn, params, body}, args, scope, opts)
      {:ok, {:fn, params, body}} ->
        evaluate_function({:fn, params, body}, args, scope, opts)
      {:ok, value} ->
        raise "Identifier #{name} is not a function, got #{inspect(value)}"
      :error ->
        raise "Function #{name} is not defined"
    end
  end

  # evaluate expression that produces a function
  defp evaluate({:fn, function_expr, args}, scope, opts) do
    {function, _} = evaluate(function_expr, scope, opts)
    evaluate_function(function, args, scope, opts)
  end

  defp evaluate({:kfcall, {:kernel_mod, _}, {:identifier, _line, name}, args}, scope, opts) do
    case String.to_atom(name) do
      :load ->
        string_uri = Enum.at(args, 0)
        {result, _} = evaluate({:import, string_uri}, scope, opts)
        {result, scope}
      _ ->
        raise "Kernel function #{name} is not defined"
    end  
  end

  # defp evaluate({:module_fn, {:identifier, line, name}, args}, scope, opts) do
  #   evaluate({:fn, {:identifier, line, name}, args}, scope, opts)
  # end

  defp evaluate({:const_fn, {:identifier, _line, name}, args}, scope, opts) do
    case Map.fetch(scope, "::#{name}") do
      {:ok, {:fn, _, params, body}} -> evaluate_function({:fn, params, body}, args, scope, opts)
      {:ok, {:fn, params, body}} -> evaluate_function({:fn, params, body}, args, scope, opts)
      :error ->
        raise "Function #{name} is not defined"
    end
  end

  # evaluate nil
  defp evaluate({:nil}, scope, _opts) do
    {nil, scope}
  end

  # evaluate boolean
  defp evaluate({:bool, _line, bool}, scope, _opts) do
    {bool, scope}
  end

  # evaluate logic

  defp evaluate({:not, expr}, scope, opts) do
    {value, _} = evaluate(expr, scope, opts)
    {!value, scope}
  end
  defp evaluate({:and, lhs, rhs}, scope, opts) do
    {lhs_v, _} = evaluate(lhs, scope, opts)
    {rhs_v, _} = evaluate(rhs, scope, opts)
    {lhs_v && rhs_v, scope}
  end

  defp evaluate({:or, lhs, rhs}, scope, opts) do
    {lhs_v, _} = evaluate(lhs, scope, opts)
    {rhs_v, _} = evaluate(rhs, scope, opts)
    {lhs_v || rhs_v, scope}
  end

  defp evaluate({:xor, lhs, rhs}, scope, opts) do
    {lhs_v, _} = evaluate(lhs, scope, opts)
    {rhs_v, _} = evaluate(rhs, scope, opts)
    {lhs_v != rhs_v, scope}
  end

  # evaluate single identifier

  defp evaluate({:identifier, _line, identifier}, scope, opts) do
    lookup = case Map.get(scope, identifier) do
      # if we find a function with 0 arity, evaluate it
      {:fn, id, [], _body} ->
        {value, _scope} = evaluate({:fn, id, []}, scope, opts)
        value
      # otherwise, return the value from scope
      value -> value
    end
    evaluate(lookup, scope, opts)
  end

  # dig through the AST
  defp evaluate([tree], scope, opts) when is_list(tree) and length(tree) > 0, do: evaluate(tree, scope, opts)
  defp evaluate([tree], scope, opts) when is_tuple(tree), do: evaluate(tree, scope, opts)

  # evaluate dangling expression
  defp evaluate([[expr] | tail], scope, opts) when is_tuple(expr) do
    {_result, updated_scope} = evaluate(expr, scope, opts)
    # continue through the AST
    evaluate(tail, updated_scope, opts)
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

  defp evaluate({:if_statement, statement, expr}, scope, opts) do
    {bool, _} = evaluate(expr, scope, opts)
    if bool do
      evaluate(statement, scope, opts)
    else
      {nil, scope}
    end
  end

  defp evaluate({:unless_statement, statement, expr}, scope, opts) do
    {bool, _} = evaluate(expr, scope, opts)
    if bool do
      {nil, scope}
    else
      evaluate(statement, scope, opts)
    end
  end

  defp evaluate({:for_loop, {:identifier, _line, var}, enum, body}, scope, opts) do
    {enum_v, _} = evaluate(enum, scope, opts)

    iterable = case enum_v do
      map when is_map(map) -> Map.keys(map) |> Enum.sort()
      list when is_list(list) -> list
      other -> raise "Cannot iterate over #{inspect(other)}"
    end

    Enum.reduce(iterable, {nil, scope}, fn item, {_acc, acc_scope} ->
      loop_scope = Map.put(acc_scope, var, item)
      evaluate(body, loop_scope, opts)
    end)
  end

  defp evaluate({:compare, {:compare, _line, operator}, lhs, rhs}, scope, opts) do
    {lhs_v, _} = evaluate(lhs, scope, opts)
    {rhs_v, _} = evaluate(rhs, scope, opts)

    result = case operator do
      "==" -> lhs_v == rhs_v
      "!=" -> lhs_v != rhs_v
      ">" -> lhs_v > rhs_v
      "<" -> lhs_v < rhs_v
      ">=" -> lhs_v >= rhs_v
      "<=" -> lhs_v <= rhs_v
      _ -> raise "Unknown comparison operator #{operator}"
    end

    {result, scope}
  end

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
      |> Enum.map(fn arg ->
        case arg do
          {:fn, _params, _body} = func -> {func, scope}
          _ -> evaluate(arg, scope, opts)
        end
      end)
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
