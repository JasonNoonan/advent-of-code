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

  def part2(_args) do
  end

  defp traverse_mathways([init | rest]) do
    recurse_numbers(rest, [init])
  end

  defp recurse_numbers([y | []], acc) do
    Enum.map(acc, fn x ->
      [x + y, x * y]
    end)
    |> List.flatten()
  end

  defp recurse_numbers([y | rest], acc) do
    acc =
      Enum.map(acc, fn x ->
        [x + y, x * y]
      end)
      |> List.flatten()

    recurse_numbers(rest, acc)
  end
end
