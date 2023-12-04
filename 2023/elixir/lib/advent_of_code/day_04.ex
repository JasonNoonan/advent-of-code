defmodule AdventOfCode.Day04 do
  import AdventOfCode.Helpers

  def score_card(nums) when nums > 1 do
    Enum.reduce(2..nums, 1, fn _v, acc ->
      acc * 2
    end)
  end

  def score_card(nums) when nums == 1, do: 1
  def score_card(_nums), do: 0

  def get_number_set(list) do
    list
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.into(MapSet.new())
  end

  def part1(args) do
    args
    |> lines()
    |> Enum.reduce(0, fn line, acc ->
      [_card, winning, mine] = String.split(line, [":", "|"], trim: true)
      winning = get_number_set(winning)
      mine = get_number_set(mine)

      winners = MapSet.intersection(winning, mine) |> MapSet.to_list()

      acc + score_card(length(winners))
    end)
  end

  def part2(_args) do
  end
end
