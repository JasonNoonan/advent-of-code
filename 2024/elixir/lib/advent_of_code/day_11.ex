defmodule AdventOfCode.Day11 do
  alias AdventOfCode.StoneMap

  def part1(args) do
    StoneMap.start_link()

    map(args)

    blink(25)
    StoneMap.get_count()
  end

  def part2(args) do
    StoneMap.start_link()

    map(args)

    blink(75)
    StoneMap.get_count()
  end

  defp map(args) do
    args
    |> String.split(["\n", " "], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> StoneMap.init()
  end

  defp blink(count), do: for(_x <- 1..count, do: StoneMap.blink())
end
