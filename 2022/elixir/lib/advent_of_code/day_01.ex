defmodule AdventOfCode.Day01 do
  def part1(args) do
    get_highest_calorie_count(args, 1)
  end

  def part2(args) do
    get_highest_calorie_count(args, 3)
  end

  def get_highest_calorie_count(list, to_take) do
    list
    |> String.split("\n\n")
    |> Enum.reduce([], fn x, acc ->
      local_count =
        x
        |> String.trim()
        |> String.split("\n")
        |> Enum.map(&String.to_integer(&1))
        |> Enum.sum()

      [local_count | acc]
    end)
    |> Enum.sort(:desc)
    |> Enum.take(to_take)
    |> Enum.sum()
  end
end
