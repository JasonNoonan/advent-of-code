defmodule AdventOfCode.Day07 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn row, outer ->
      [test_value, numbers] = String.split(row, ": ", trim: true)
      test_value = String.to_integer(test_value)

      results =
        numbers
        |> String.split(" ")
        |> Enum.map(&String.to_integer/1)
        |> traverse_mathways()

      if Enum.any?(results, fn x -> x == test_value end) do
        outer + test_value
      else
        outer
      end
    end)
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn row, outer ->
      [test_value, numbers] = String.split(row, ": ", trim: true)
      test_value = String.to_integer(test_value)

      results =
        numbers
        |> String.split(" ")
        |> Enum.map(&String.to_integer/1)
        |> traverse_mathways(true)

      if Enum.any?(results, fn x -> x == test_value end) do
        outer + test_value
      else
        outer
      end
    end)
  end

  defp traverse_mathways([init | rest], concat? \\ false) do
    recurse_numbers(rest, [init], concat?)
  end

  defp recurse_numbers([y | []], acc, concat?) do
    Enum.map(acc, fn x ->
      if concat? do
        [x + y, x * y, concat_numbers(x, y)]
      else
        [x + y, x * y]
      end
    end)
    |> List.flatten()
  end

  defp recurse_numbers([y | rest], acc, concat?) do
    acc =
      Enum.map(acc, fn x ->
        if concat? do
          [x + y, x * y, concat_numbers(x, y)]
        else
          [x + y, x * y]
        end
      end)
      |> List.flatten()

    recurse_numbers(rest, acc, concat?)
  end

  defp concat_numbers(x, y) do
    (Integer.to_string(x) <> Integer.to_string(y))
    |> String.to_integer()
  end
end
