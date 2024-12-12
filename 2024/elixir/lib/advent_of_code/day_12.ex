defmodule AdventOfCode.Day12 do
  alias AdventOfCode.Helpers

  def part1(args) do
    map_args(args)
    |> Helpers.list_to_map()
    |> map_to_graph()
    |> Map.values()
    |> List.flatten()
    |> Enum.reduce(0, fn g, acc ->
      acc + calculate_lumber_cost(g)
    end)
  end

  def part2(_args) do
  end

  defp map_args(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp map_to_graph(map) do
    Enum.sort_by(map, &{elem(elem(&1, 0), 0), elem(elem(&1, 0), 1)})
    |> Enum.reduce(%{}, fn {{x, y}, plant}, farm ->
      my_plot = find_plot_on_farm!(farm, plant, {x, y})
      farm = Map.update(farm, plant, [my_plot], fn g -> update_farm(g, {x, y}) end)

      Enum.reduce(Helpers.get_adj(map, {x, y}), farm, fn
        {{nx, ny}, ^plant}, f ->
          update_plot_on_farm(f, plant, {x, y}, {nx, ny})

        {_coords, _plant}, f ->
          f
      end)
    end)
  end

  defp find_plot_on_farm!(farm, plant, coords) when is_map_key(farm, plant) do
    Map.get(farm, plant)
    |> Enum.find(fn g -> Graph.has_vertex?(g, coords) end)
    |> case do
      nil ->
        Graph.new() |> Graph.add_vertex(coords)

      g ->
        g
    end
  end

  defp find_plot_on_farm!(_farm, _plant, coords), do: Graph.new() |> Graph.add_vertex(coords)

  defp update_farm(graphs, coords) when is_list(graphs) and length(graphs) > 1 do
    case Enum.find(graphs, &Graph.has_vertex?(&1, coords)) do
      nil ->
        [Graph.new() |> Graph.add_vertex(coords) | graphs]

      _graph ->
        graphs
    end
  end

  defp update_farm([graph], coords) do
    [Graph.add_vertex(graph, coords)]
  end

  defp update_plot_on_farm(farm, _plant, base, base), do: farm

  defp update_plot_on_farm(farm, plant, base, neighbor) do
    Map.update!(farm, plant, fn graphs ->
      Enum.map(graphs, fn g ->
        if Graph.has_vertex?(g, base) do
          Graph.add_edge(g, base, neighbor)
        else
          g
        end
      end)
    end)
  end

  defp calculate_lumber_cost(graph) do
    dbg(graph)
    area = Graph.vertices(graph) |> Enum.count() |> dbg()

    circumference =
      Graph.Reducers.Dfs.reduce(graph, 0, fn v, x ->
        {:next, x + (4 - (Graph.in_edges(graph, v) |> Enum.count()))}
      end)
      |> dbg()

    area * circumference
  end
end
