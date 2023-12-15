defmodule AdventOfCode.Day15 do
  import AdventOfCode.Helpers

  def hashmap(label) do
    label
    |> String.to_charlist()
    |> Enum.reduce(0, fn c, acc ->
      acc
      |> Kernel.+(c)
      |> Kernel.*(17)
      |> rem(256)
    end)
  end

  def part1(args) do
    args
    |> lines()
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> List.flatten()
    |> Enum.map(&hashmap/1)
    |> Enum.sum()
  end

end
