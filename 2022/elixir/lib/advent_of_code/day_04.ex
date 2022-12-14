defmodule AdventOfCode.Day04 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn curr, acc ->
      [a, b] = String.split(curr, ",")
      [ax, ay] = String.split(a, "-") |> Enum.map(&String.to_integer/1)
      [bx, by] = String.split(b, "-") |> Enum.map(&String.to_integer/1)
      a = MapSet.new(ax..ay)
      b = MapSet.new(bx..by)

      int = MapSet.intersection(a, b)
      update = if MapSet.equal?(int, a) || MapSet.equal?(int, b), do: 1, else: 0
      acc + update
    end)
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn curr, acc ->
      [a, b] = String.split(curr, ",")
      [ax, ay] = String.split(a, "-") |> Enum.map(&String.to_integer/1)
      [bx, by] = String.split(b, "-") |> Enum.map(&String.to_integer/1)
      a = MapSet.new(ax..ay)
      b = MapSet.new(bx..by)

      update = if MapSet.size(MapSet.intersection(a, b)) > 0, do: 1, else: 0
      acc + update
    end)
    |> dbg
  end
end
