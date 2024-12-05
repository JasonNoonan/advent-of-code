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
      [first, second] = String.split(rule, "|")

      Map.update(acc, second, [first], fn c -> [first | c] end)
    end)
  end

  defp parse_updates(updates, rules) do
    Enum.reduce(updates, [], fn row, acc ->
      print_order = String.split(row, ",")

      if is_sorted?(print_order, rules) do
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

      if is_sorted?(print_order, rules) do
        acc
      else
        [print_order | acc]
      end
    end)
  end

  # only account for odd row lengths
  defp get_middle_index(print_order) do
    print_order
    |> Enum.count()
    |> Integer.floor_div(2)
  end

  defp fix_ordering(print_orders, rules) do
    Enum.reduce(print_orders, [], fn row, acc ->
      page_numbers = Enum.map(row, fn x -> x end)

      sorted = sort_pages(page_numbers, rules)

      middle_index = get_middle_index(sorted)

      [Enum.at(sorted, middle_index) | acc]
    end)
  end

  defp sort_pages(print_order, rules) do
    Enum.sort(print_order, fn x, y ->
      Map.has_key?(rules, y) and x in rules[y]
    end)
  end

  defp is_sorted?(print_order, rules) do
    print_order == sort_pages(print_order, rules)
  end
end
