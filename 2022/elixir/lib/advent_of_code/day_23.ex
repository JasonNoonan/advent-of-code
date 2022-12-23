defmodule AdventOfCode.Day23 do
  def parse(args) do
    for {line, y} <- String.split(args) |> Enum.with_index(), reduce: %{} do
      grid ->
        for {char, x} <- String.graphemes(line) |> Enum.with_index(), reduce: grid do
          inner ->
            if char == "#", do: Map.put(inner, "#{x},#{y}", {x, y}), else: inner
        end
    end
    |> dbg
  end

  def part1(args) do
    args
    |> parse()
  end

  def part2(_args) do
  end
end
