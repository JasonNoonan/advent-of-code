defmodule AdventOfCode.Day10 do
  alias AdventOfCode.Helpers

  def part1(args) do
    map = parse_map(args)
    start_locations = get_positions_by_height(map, 0)
    targets = get_positions_by_height(map, 9)
    graph = map_to_graph(map)

    for th <- start_locations, reduce: 0 do
      acc ->
        for tar <- targets, reduce: acc do
          inner ->
            if Graph.dijkstra(graph, th, tar), do: inner + 1, else: inner
        end
    end
  end

  def part2(args) do
    map = parse_map(args)
    start_locations = get_positions_by_height(map, 0)
    targets = get_positions_by_height(map, 9)
    graph = map_to_graph(map)

    for th <- start_locations, reduce: 0 do
      paths ->
        for t <- targets, reduce: paths do
          acc ->
            acc + (Graph.get_paths(graph, th, t) |> Enum.count())
        end
    end
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
    |> Enum.sort_by(&{elem(elem(&1, 0), 0), elem(elem(&1, 0), 1)})
  end

  defp map_to_graph(map) do
    Enum.reduce(map, Graph.new(), fn {point, val}, graph ->
      # graph = Graph.add_vertex(graph, {point, val})

      for {p, v} <- Helpers.get_adj(map, point, all: false), reduce: graph do
        g ->
          if v - val == 1 do
            Graph.add_edge(g, {point, val}, {p, v})
          else
            g
          end
      end
    end)
  end
end
