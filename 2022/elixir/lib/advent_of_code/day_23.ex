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

  def find_neigbors({x, y}, positions) do
    dirs = %{
      nw: "#{x - 1},#{y - 1}",
      n: "#{x},#{y - 1}",
      ne: "#{x + 1},#{y - 1}",
      e: "#{x + 1},#{y}",
      se: "#{x + 1},#{y + 1}",
      s: "#{x},#{y + 1}",
      sw: "#{x - 1},#{y + 1}",
      w: "#{x - 1},#{y}"
    }

    %{
      nw: Map.get(positions, dirs.nw),
      n: Map.get(positions, dirs.n),
      ne: Map.get(positions, dirs.ne),
      e: Map.get(positions, dirs.e),
      se: Map.get(positions, dirs.se),
      s: Map.get(positions, dirs.s),
      sw: Map.get(positions, dirs.sw),
      w: Map.get(positions, dirs.w)
    }
  end

  def part1(args) do
    priority = [:n, :s, :w, :e]

    starting_positions =
      args
      |> parse()
  end

  def part2(_args) do
  end
end
