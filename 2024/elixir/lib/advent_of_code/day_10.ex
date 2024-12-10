defmodule AdventOfCode.Day10 do
  alias AdventOfCode.Helpers

  def part1(args) do
    map = parse_map(args)
    start_locations = get_positions_by_height(map, 0)
    targets = get_positions_by_height(map, 9)

    for {th, _v} <- start_locations, reduce: 0 do
      acc ->
        for {tar, _val} <- targets do
          cost =
            Helpers.dijkstras(map, th, tar, fn
              cost, start, next when next - start == 1 ->
                cost

              _cost, _start, _next ->
                :infinity
            end)

          # cost 0 means we found a happy path
          if cost == 0, do: 1, else: 0
        end
        |> Enum.sum()
        |> Kernel.+(acc)
    end
  end

  def part2(_args) do
  end

  defp parse_map(args) do
    args
    |> Helpers.lines()
    |> Enum.map(fn x ->
      x
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Helpers.list_to_map()
  end

  defp get_positions_by_height(map, target_height) do
    map
    |> Enum.filter(fn
      {_coords, ^target_height} -> true
      _else -> false
    end)
  end
end
