defmodule AdventOfCode.Day12 do
  @doc """
    iex> AdventOfCode.Day12.parse("Sabqponm\\nabcryxxl\\naccszExk\\nacctuvwj\\nabdefghi")
    [
      %{type: :start, value: "a", x: 0, y: 0}, %{type: :node, value: "a", x: 1, y: 0}, %{type: :node, value: "b", x: 2, y: 0}, %{type: :node, value: "q", x: 3, y: 0}, %{type: :node, value: "p", x: 4, y: 0}, %{type: :node, value: "o", x: 5, y: 0}, %{type: :node, value: "n", x: 6, y: 0}, %{type: :node, value: "m", x: 7, y: 0},
      %{type: :node, value: "a", x: 0, y: 1}, %{type: :node, value: "b", x: 1, y: 1}, %{type: :node, value: "c", x: 2, y: 1}, %{type: :node, value: "r", x: 3, y: 1}, %{type: :node, value: "y", x: 4, y: 1}, %{type: :node, value: "x", x: 5, y: 1}, %{type: :node, value: "x", x: 6, y: 1}, %{type: :node, value: "l", x: 7, y: 1},
      %{type: :node, value: "a", x: 0, y: 2}, %{type: :node, value: "c", x: 1, y: 2}, %{type: :node, value: "c", x: 2, y: 2}, %{type: :node, value: "s", x: 3, y: 2}, %{type: :node, value: "z", x: 4, y: 2}, %{type: :goal, value: "z", x: 5, y: 2}, %{type: :node, value: "x", x: 6, y: 2}, %{type: :node, value: "k", x: 7, y: 2},
      %{type: :node, value: "a", x: 0, y: 3}, %{type: :node, value: "c", x: 1, y: 3}, %{type: :node, value: "c", x: 2, y: 3}, %{type: :node, value: "t", x: 3, y: 3}, %{type: :node, value: "u", x: 4, y: 3}, %{type: :node, value: "v", x: 5, y: 3}, %{type: :node, value: "w", x: 6, y: 3}, %{type: :node, value: "j", x: 7, y: 3},
      %{type: :node, value: "a", x: 0, y: 4}, %{type: :node, value: "b", x: 1, y: 4}, %{type: :node, value: "d", x: 2, y: 4}, %{type: :node, value: "e", x: 3, y: 4}, %{type: :node, value: "f", x: 4, y: 4}, %{type: :node, value: "g", x: 5, y: 4}, %{type: :node, value: "h", x: 6, y: 4}, %{type: :node, value: "i", x: 7, y: 4}
    ]
  """
  def parse(args) do
    mapped_graph =
      args
      |> String.split()
      |> Enum.with_index()
      |> Enum.reduce([], fn {line, y_index}, graph ->
        mapped_row =
          String.graphemes(line)
          |> Enum.with_index()
          |> Enum.reduce([], fn {char, x_index}, row ->
            char_map =
              case char do
                "S" -> %{type: :start, value: "a", x: x_index, y: y_index}
                "E" -> %{type: :goal, value: "z", x: x_index, y: y_index}
                _ -> %{type: :node, value: char, x: x_index, y: y_index}
              end

            [char_map | row]
          end)
          |> Enum.reverse()

        [mapped_row | graph]
      end)

    mapped_graph
    |> Enum.reverse()
    |> List.flatten()
  end

  def parse_graph(mapped_graph) do
    {graph, start, goal} =
      Enum.reduce(mapped_graph, {Graph.new(), nil, nil}, fn vertex, {acc, start, goal} ->
        vertex_name = to_string(vertex.x) <> "-" <> to_string(vertex.y)
        start = if vertex.type == :start, do: vertex_name, else: start
        goal = if vertex.type == :goal, do: vertex_name, else: goal

        graph =
          find_neighbors(vertex, mapped_graph)
          |> Enum.reduce(acc, fn x, g ->
            name = to_string(x.x) <> "-" <> to_string(x.y)
            neighbor = get_value(x.value)
            me = get_value(vertex.value)

            if neighbor > me + 1,
              do: g,
              else: Graph.add_edge(g, vertex_name, name)
          end)

        {graph, start, goal}
      end)

    {graph, start, goal}
  end

  @doc """
    iex> AdventOfCode.Day12.find_neighbors(%{type: :start, value: "a", x: 0, y: 0}, [
    ...>%{type: :start, value: "a", x: 0, y: 0}, %{type: :node, value: "a", x: 1, y: 0}, %{type: :node, value: "b", x: 2, y: 0}, %{type: :node, value: "q", x: 3, y: 0}, %{type: :node, value: "p", x: 4, y: 0}, %{type: :node, value: "o", x: 5, y: 0}, %{type: :node, value: "n", x: 6, y: 0}, %{type: :node, value: "m", x: 7, y: 0},
    ...>%{type: :node, value: "a", x: 0, y: 1}, %{type: :node, value: "b", x: 1, y: 1}, %{type: :node, value: "c", x: 2, y: 1}, %{type: :node, value: "r", x: 3, y: 1}, %{type: :node, value: "y", x: 4, y: 1}, %{type: :node, value: "x", x: 5, y: 1}, %{type: :node, value: "x", x: 6, y: 1}, %{type: :node, value: "l", x: 7, y: 1},
    ...>%{type: :node, value: "a", x: 0, y: 2}, %{type: :node, value: "c", x: 1, y: 2}, %{type: :node, value: "c", x: 2, y: 2}, %{type: :node, value: "s", x: 3, y: 2}, %{type: :node, value: "z", x: 4, y: 2}, %{type: :goal, value: "z", x: 5, y: 2}, %{type: :node, value: "x", x: 6, y: 2}, %{type: :node, value: "k", x: 7, y: 2},
    ...>%{type: :node, value: "a", x: 0, y: 3}, %{type: :node, value: "c", x: 1, y: 3}, %{type: :node, value: "c", x: 2, y: 3}, %{type: :node, value: "t", x: 3, y: 3}, %{type: :node, value: "u", x: 4, y: 3}, %{type: :node, value: "v", x: 5, y: 3}, %{type: :node, value: "w", x: 6, y: 3}, %{type: :node, value: "j", x: 7, y: 3},
    ...>%{type: :node, value: "a", x: 0, y: 4}, %{type: :node, value: "b", x: 1, y: 4}, %{type: :node, value: "d", x: 2, y: 4}, %{type: :node, value: "e", x: 3, y: 4}, %{type: :node, value: "f", x: 4, y: 4}, %{type: :node, value: "g", x: 5, y: 4}, %{type: :node, value: "h", x: 6, y: 4}, %{type: :node, value: "i", x: 7, y: 4}
    ...>])
    [%{type: :node, value: "a", x: 0, y: 1}, %{type: :node, value: "a", x: 1, y: 0}]
  """
  def find_neighbors(%{type: _, value: _, x: x, y: y}, graph) do
    north =
      Enum.find(graph, fn %{type: _, value: _, x: tx, y: ty} ->
        tx == x and ty == y + 1
      end)

    south = Enum.find(graph, fn %{type: _, value: _, x: tx, y: ty} -> tx == x and ty == y - 1 end)
    east = Enum.find(graph, fn %{type: _, value: _, x: tx, y: ty} -> tx == x + 1 and ty == y end)
    west = Enum.find(graph, fn %{type: _, value: _, x: tx, y: ty} -> tx == x - 1 and ty == y end)

    [north, south, east, west]
    |> Enum.reject(fn x -> is_nil(x) end)
  end

  def get_value(char) do
    {_, value} =
      "abcdefghijklmnopqrstuvwxyz"
      |> String.graphemes()
      |> Enum.with_index(1)
      |> Enum.find(fn {x, _value} -> x == char end)

    value
  end

  @doc """
    iex> AdventOfCode.Day12.part1("Sabqponm\\nabcryxxl\\naccszExk\\nacctuvwj\\nabdefghi")
    31
  """
  def part1(args) do
    {graph, start, goal} = parse(args) |> parse_graph()

    path_length = Graph.dijkstra(graph, start, goal) |> length |> dbg
    path_length - 1
  end

  def part2(_args) do
  end
end
