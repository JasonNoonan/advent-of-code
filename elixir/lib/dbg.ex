defmodule AdventOfCode.Dbg do
  alias Code.Identifier

  def unpipe(expr) do
    :lists.reverse(unpipe(expr, []))
  end

  defp unpipe({:|>, _, [left, right]}, acc) do
    unpipe(right, unpipe(left, acc))
  end

  defp unpipe(other, acc) do
    [{other, 0} | acc]
  end

  def pipe(expr, call_args, position)

  def pipe(expr, {:&, _, _} = call_args, _integer) do
    raise ArgumentError, bad_pipe(expr, call_args)
  end

  def pipe(expr, {tuple_or_map, _, _} = call_args, _integer) when tuple_or_map in [:{}, :%{}] do
    raise ArgumentError, bad_pipe(expr, call_args)
  end

  # Without this, `Macro |> Env == Macro.Env`.
  def pipe(expr, {:__aliases__, _, _} = call_args, _integer) do
    raise ArgumentError, bad_pipe(expr, call_args)
  end

  def pipe(expr, {:<<>>, _, _} = call_args, _integer) do
    raise ArgumentError, bad_pipe(expr, call_args)
  end

  def pipe(expr, {unquote, _, []}, _integer) when unquote in [:unquote, :unquote_splicing] do
    raise ArgumentError,
          "cannot pipe #{to_string(expr)} into the special form #{unquote}/1 " <>
            "since #{unquote}/1 is used to build the Elixir AST itself"
  end

  # {:fn, _, _} is what we get when we pipe into an anonymous function without
  # calling it, for example, `:foo |> (fn x -> x end)`.
  def pipe(expr, {:fn, _, _}, _integer) do
    raise ArgumentError,
          "cannot pipe #{to_string(expr)} into an anonymous function without" <>
            " calling the function; use Kernel.then/2 instead or" <>
            " define the anonymous function as a regular private function"
  end

  def pipe(expr, {call, line, atom}, integer) when is_atom(atom) do
    {call, line, List.insert_at([], integer, expr)}
  end

  def pipe(_expr, {op, _line, [arg]}, _integer) when op == :+ or op == :- do
    raise ArgumentError,
          "piping into a unary operator is not supported, please use the qualified name: " <>
            "Kernel.#{op}(#{to_string(arg)}), instead of #{op}#{to_string(arg)}"
  end

  def pipe(expr, {op, line, args} = op_args, integer) when is_list(args) do
    cond do
      is_atom(op) and operator?(op, 1) ->
        raise ArgumentError,
              "cannot pipe #{to_string(expr)} into #{to_string(op_args)}, " <>
                "the #{to_string(op)} operator can only take one argument"

      is_atom(op) and operator?(op, 2) ->
        raise ArgumentError,
              "cannot pipe #{to_string(expr)} into #{to_string(op_args)}, " <>
                "the #{to_string(op)} operator can only take two arguments"

      true ->
        {op, line, List.insert_at(args, integer, expr)}
    end
  end

  def pipe(expr, call_args, _integer) do
    raise ArgumentError, bad_pipe(expr, call_args)
  end

  defp bad_pipe(expr, call_args) do
    "cannot pipe #{to_string(expr)} into #{to_string(call_args)}, " <>
      "can only pipe into local calls foo(), remote calls Foo.bar() or anonymous function calls foo.()"
  end

  def operator?(name, arity)

  def operator?(:"..//", 3),
    do: true

  # Code.Identifier treats :// as a binary operator for precedence
  # purposes but it isn't really one, so we explicitly skip it.
  def operator?(name, 2) when is_atom(name),
    do: Identifier.binary_op(name) != :error and name != :"//"

  def operator?(name, 1) when is_atom(name),
    do: Identifier.unary_op(name) != :error

  def operator?(:.., 0),
    do: true

  def operator?(name, arity) when is_atom(name) and is_integer(arity), do: false

  def dbg(code, options, _caller, _device) do
    dbg(code, options, __ENV__)
  end

  def dbg(code, options, %Macro.Env{} = env) do
    case env.context do
      :match ->
        raise ArgumentError,
              "invalid expression in match, dbg is not allowed in patterns " <>
                "such as function clauses, case clauses or on the left side of the = operator"

      :guard ->
        raise ArgumentError,
              "invalid expression in guard, dbg is not allowed in guards. " <>
                "To learn more about guards, visit: https://hexdocs.pm/elixir/patterns-and-guards.html"

      _ ->
        :ok
    end

    header = dbg_format_header(env)

    quote do
      to_debug = unquote(dbg_ast_to_debuggable(code))
      unquote(__MODULE__).__dbg__(unquote(header), to_debug, unquote(options))
    end
  end

  # Pipelines.
  defp dbg_ast_to_debuggable({:|>, _meta, _args} = pipe_ast) do
    value_var = Macro.unique_var(:value, __MODULE__)
    values_acc_var = Macro.unique_var(:values, __MODULE__)

    [start_ast | rest_asts] = asts = for {ast, 0} <- unpipe(pipe_ast), do: ast
    rest_asts = Enum.map(rest_asts, &pipe(value_var, &1, 0))

    start_timer_ast =
      quote do
        unquote(
          quote do
            :timer.tc(unquote(start_ast))
          end
        )
      end

    initial_acc =
      quote do
        unquote(value_var) = unquote(start_timer_ast)
        unquote(values_acc_var) = [unquote(value_var)]
      end

    values_ast =
      for step_ast <- rest_asts, reduce: initial_acc do
        ast_acc ->
          value_var =
            quote do
              unquote(
                quote do
                  :timer.tc(unquote(step_ast))
                end
              )
            end

          quote do
            unquote(ast_acc)
            unquote(values_acc_var) = [unquote(value_var) | unquote(values_acc_var)]
          end
      end

    quote do
      unquote(values_ast)

      {:pipe, unquote(Macro.escape(asts)), Enum.reverse(unquote(values_acc_var))}
    end
  end

  # Any other AST.
  defp dbg_ast_to_debuggable(ast) do
    quote do: {:value, unquote(Macro.escape(ast)), unquote(ast)}
  end

  # Made public to be called from Macro.dbg/3, so that we generate as little code
  # as possible and call out into a function as soon as we can.
  @doc false
  def __dbg__(header_string, to_debug, options) do
    {print_location?, options} = Keyword.pop(options, :print_location, true)
    syntax_colors = if IO.ANSI.enabled?(), do: IO.ANSI.syntax_colors(), else: []
    options = Keyword.merge([width: 80, pretty: true, syntax_colors: syntax_colors], options)

    {formatted, result} = dbg_format_ast_to_debug(to_debug, options)

    formatted =
      if print_location? do
        [:cyan, :italic, header_string, :reset, "\n", formatted, "\n"]
      else
        [formatted, "\n"]
      end

    ansi_enabled? = options[:syntax_colors] != []
    :ok = IO.write(IO.ANSI.format(formatted, ansi_enabled?))

    result
  end

  defp dbg_format_ast_to_debug({:pipe, code_asts, values}, options) do
    result = List.last(values)
    code_strings = Enum.map(code_asts, &to_string_with_colors(&1, options))
    [{first_ast, first_value} | asts_with_values] = Enum.zip(code_strings, values)
    first_formatted = [dbg_format_ast(first_ast), " ", inspect(first_value, options), ?\n]

    rest_formatted =
      Enum.map(asts_with_values, fn {code_ast, value} ->
        [:faint, "|> ", :reset, dbg_format_ast(code_ast), " ", inspect(value, options), ?\n]
      end)

    {[first_formatted | rest_formatted], result}
  end

  defp dbg_format_ast_to_debug({:value, code_ast, value}, options) do
    code = to_string_with_colors(code_ast, options)
    {[dbg_format_ast(code), " ", inspect(value, options), ?\n], value}
  end

  defp to_string_with_colors(ast, options) do
    options = Keyword.take(options, [:syntax_colors])

    algebra = Code.quoted_to_algebra(ast, options)
    IO.iodata_to_binary(Inspect.Algebra.format(algebra, 98))
  end

  defp dbg_format_header(env) do
    env = Map.update!(env, :file, &(&1 && Path.relative_to_cwd(&1)))
    [stacktrace_entry] = Macro.Env.stacktrace(env)
    "[" <> Exception.format_stacktrace_entry(stacktrace_entry) <> "]"
  end

  defp dbg_format_ast(ast) do
    [ast, :faint, " #=>", :reset]
  end
end
