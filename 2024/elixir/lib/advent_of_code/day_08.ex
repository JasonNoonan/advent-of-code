defmodule AdventOfCode.Day08 do
  alias AdventOfCode.Helpers

  def part1(args) do
    map =
      args
      |> Helpers.lines()
      |> Enum.map(&String.graphemes/1)
      |> Helpers.list_to_map()

    symbols_map = Enum.reject(map, fn {_coords, symbol} -> symbol == "." end)

    Enum.reduce(symbols_map, [], fn {coords, symbol}, antinodes ->
      Enum.reduce(symbols_map, antinodes, fn
        {^coords, ^symbol}, acc ->
          acc

        {target, ^symbol}, a_nodes ->
          antinode = map_antinode(coords, target)

          [antinode | a_nodes]

        {_other, _other_symbol}, acc ->
          acc
      end)
    end)
    |> Enum.uniq()
    |> Enum.count(fn {x, y} -> Map.get(map, {x, y}) end)
  end

  def part2(_args) do
  end

  defp map_antinode({x1, y1}, {x2, y2}) do
    {x1 + (x1 - x2), y1 + (y1 - y2)}
  end
end
