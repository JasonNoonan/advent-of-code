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

  def part2(args) do
    map =
      args
      |> Helpers.lines()
      |> Enum.map(&String.graphemes/1)
      |> Helpers.list_to_map()

    symbols_map =
      Enum.reject(map, fn {_coords, symbol} -> symbol == "." end)

    symbol_slopes = get_all_symbol_slopes(symbols_map) |> MapSet.to_list()

    Enum.reduce(map, MapSet.new(), fn {{x, y}, _symbol}, acc ->
      if Enum.reduce_while(symbol_slopes, false, fn
           {:infinity, {x1, _y1}, {_x2, _y2}}, inner ->
             if x == x1, do: {:halt, true}, else: {:cont, inner}

           {m, b}, inner ->
             if Helpers.in_line?({x, y}, m, b), do: {:halt, true}, else: {:cont, inner}
         end),
         do: MapSet.put(acc, {x, y}),
         else: acc
    end)
    |> MapSet.to_list()
    |> Enum.count()
  end

  defp map_antinode({x1, y1}, {x2, y2}) do
    {x1 + (x1 - x2), y1 + (y1 - y2)}
  end

  defp get_all_symbol_slopes(symbols_map) do
    Enum.reduce(symbols_map, MapSet.new(), fn {coords, symbol}, slopes ->
      Enum.reduce(symbols_map, slopes, fn
        {^coords, ^symbol}, acc ->
          acc

        {target, ^symbol}, slopes ->
          results =
            case Helpers.find_slope(coords, target) do
              {:ok, {m, b}} -> {m, b}
              {:error, :undefined} -> {:infinity, coords, target}
            end

          MapSet.put(slopes, results)

        {_other, _other_symbol}, acc ->
          acc
      end)
    end)
  end
end
