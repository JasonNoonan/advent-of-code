defmodule AdventOfCode.Day05 do
  import AdventOfCode.Helpers

  def get_seeds(seeds) do
    seeds
    |> String.replace("seeds: ", "")
    |> String.split(" ")
  end

  def get_map_intervals(maps) do
    for map <- maps do
      map
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.reduce([], fn ranges, acc ->
        [destination | [source | [range]]] =
          String.split(ranges, " ") |> Enum.map(&String.to_integer/1)

        [{source, source + range - 1, destination - source} | acc]
      end)
    end
  end

  def break_intervals(init, map) when length(init) < 1, do: map

  def break_intervals(prev, next) do
    for {p_start, p_end, p_op} = p <- prev do
      for {n_start, n_end, n_op} <- next, reduce: [p] do
        acc ->
          dbg([p, {n_start, n_end, n_op}])

          cond do
            p_end < n_start or p_start > n_end ->
              acc

            p_start < n_start and p_end < n_end ->
              [
                [
                  {p_start, n_start - 1, p_op},
                  {n_start, p_end, p_op + n_op}
                ]
              ]

            p_start > n_start and p_end < n_end ->
              [[{p_start, p_end, p_op + n_op}] | acc]

            p_start > n_start and p_end > n_end ->
              [
                [
                  {p_start, n_end, p_op + n_op},
                  {n_end + 1, p_end, p_op}
                ]
              ]

            p_start < n_start and p_end > n_end ->
              [
                [
                  {p_start, n_start - 1, p_op},
                  {n_start, n_end, p_op + n_op},
                  {n_end + 1, p_end, p_op}
                ]
              ]
          end
      end
    end
    |> List.flatten()
    |> dbg
  end

  def get_seed_intervals(seeds, intervals) when is_list(seeds) do
    [seeds | intervals]
  end

  def part1(args) do
    [seeds | maps] = String.split(args, "\n\n", trim: true)
    maps = get_map_intervals(maps)

    seeds
    |> get_seeds()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce([], fn seed, acc -> [{seed, seed, 0} | acc] end)
    |> get_seed_intervals(maps)
    |> Enum.take(2)
    |> Enum.reduce([], fn map, acc ->
      dbg(%{map: map, acc: acc})
      break_intervals(acc, map)
    end)
  end

  def part2(_args) do
  end
end
