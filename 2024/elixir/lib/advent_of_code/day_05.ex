defmodule AdventOfCode.Day05 do
  alias AdventOfCode.Helpers

  def part1(args) do
    [rules, updates] =
      args
      |> Helpers.divided_lines()

    rules = parse_rules(rules)

    parse_updates(updates, rules)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def part2(args) do
    [rules, updates] =
      args
      |> Helpers.divided_lines()

    rules = parse_rules(rules)

    find_failed_orders(updates, rules)
    |> fix_ordering(rules)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  defp parse_rules(rules) do
    Enum.reduce(rules, %{}, fn rule, acc ->
      [first | second] = String.split(rule, "|")

      # has to be a less dumb way to do this?
      [second | _none] = second

      acc
      |> Map.update(first, %{before: [second]}, fn c ->
        Map.update(c, :before, [second], fn curr -> [second | curr] end)
      end)
      |> Map.update(second, %{after: [first]}, fn c ->
        Map.update(c, :after, [first], fn curr -> [first | curr] end)
      end)
    end)
  end

  defp parse_updates(updates, rules) do
    Enum.reduce(updates, [], fn row, acc ->
      print_order =
        row
        |> String.split(",")
        |> Enum.with_index()

      if is_correct_order?(print_order, rules) do
        print_order =
          print_order
          |> Enum.map(fn {x, _i} -> x end)

        middle_index = get_middle_index(print_order)
        [Enum.at(print_order, middle_index) | acc]
      else
        acc
      end
    end)
  end

  defp find_failed_orders(updates, rules) do
    Enum.reduce(updates, [], fn row, acc ->
      print_order =
        row
        |> String.split(",")
        |> Enum.with_index()

      if is_correct_order?(print_order, rules) do
        acc
      else
        [print_order | acc]
      end
    end)
  end

  defp is_correct_order?(print_order, rules) do
    Enum.all?(print_order, fn {x, i} ->
      is_correctly_before?(x, print_order, i, rules)
      is_correctly_after?(x, print_order, i, rules)
    end)
  end

  defp is_correctly_before?(term, members, index, rules) do
    items_after =
      Enum.reduce(members, [], fn {x, i}, acc ->
        if i > index, do: [x | acc], else: acc
      end)

    # none of the items after me should have a rules stating they should
    # be printed before me
    Enum.all?(items_after, fn x ->
      if Map.has_key?(rules, x) and Map.has_key?(rules[x], :before) do
        before_list = rules[x][:before]
        term not in before_list
      else
        true
      end
    end)
  end

  defp is_correctly_after?(term, members, index, rules) do
    items_before =
      Enum.reduce(members, [], fn {x, i}, acc ->
        if i < index, do: [x | acc], else: acc
      end)

    # none of the items before me should have rules stating they should
    # be printed after me
    Enum.all?(items_before, fn x ->
      if Map.has_key?(rules, x) and Map.has_key?(rules[x], :after) do
        after_list = rules[x][:after]
        term not in after_list
      else
        true
      end
    end)
  end

  defp get_middle_index(print_order) do
    count =
      print_order
      |> Enum.count()

    index = Integer.floor_div(count, 2)

    if rem(count, 2) == 0 do
      index - 1
    else
      index
    end
  end

  defp fix_ordering(print_orders, rules) do
    Enum.reduce(print_orders, [], fn row, acc ->
      page_numbers = Enum.map(row, fn {x, _i} -> x end)

      sorted =
        Enum.sort(page_numbers, fn x, y ->
          try_rules(x, y, rules)
        end)

      middle_index = get_middle_index(sorted)

      [Enum.at(sorted, middle_index) | acc]
    end)
  end

  defp try_rules(x, y, rules) do
    if try_rule(x, y, rules, :x_before) do
      true
    else
      false
    end
  end

  defp try_rule(x, y, rules, :x_before) do
    if Map.has_key?(rules, x) and Map.has_key?(rules[x], :before) and y in rules[x][:before] do
      true
    else
      try_rule(x, y, rules, :y_after)
    end
  end

  defp try_rule(x, y, rules, :y_after) do
    Map.has_key?(rules, y) and Map.has_key?(rules[y], :after) and x in rules[y][:after]
  end
end
