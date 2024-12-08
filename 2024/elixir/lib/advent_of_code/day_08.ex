defmodule AdventOfCode.Day08 do
  alias AdventOfCode.Helpers

  def part1(args) do
    map =
      args
      |> Helpers.lines()
      |> Helpers.list_to_map()

    symbols_map = Enum.reject(map, fn {coords, symbol} -> symbol != "." end)
    symbol_slopes = get_all_symbol_slopes(symbols_map)

    # iterate over full map and for each location, find the slope of the
    # current location and a symbol from the symbol_slopes map. If they match,
    # determine if the current point is twice as far from point A as it is from
    # point B, or twice as far from point B as it is from point A

    # If so, we have an antinode. Otherwise, move on. Reminder that even
    # locations that have a current symbol can be antinodes.
  end

  def part2(_args) do
  end

  defp get_all_symbol_slopes(symbols_map) do
    Enum.reduce(symbols_map, %{}, fn {{x, y}, symbol}, acc ->
      Enum.filter(symbols_map, fn
        {coords, ^symbol} ->
          # matching symbols and we haven't already calculated either direction
          # of a->b or b->a for this line
          # and not our same, current symbol location
          not line_already_calculated?(symbol, {x, y}, coords, acc) and
            {x, y} != coords

        {_coords, _symbol} ->
          false
      end)
      |> Enum.reduce(acc, fn {{x2, y2}, _sym}, inner ->
        case Helpers.find_slope({x, y}, {x2, y2}) do
          {:ok, {m, b}} ->
            Map.put(inner, {symbol, {x, y}}, {m, b})

          {:error, :undefined} ->
            Map.put(inner, {symbol, {x, y}, {:infinity, 0}})

          _else ->
            inner
        end
      end)
    end)
  end

  defp line_already_calculated?(symbol, a, b, map) do
    a_list = Map.get(map, {symbol, a})
    b_list = Map.get(map, {symbol, b})

    (not is_nil(a_list) and {symbol, b} in a_list) or
      (not is_nil(b_list) and {symbol, a} in b_list)
  end
end
