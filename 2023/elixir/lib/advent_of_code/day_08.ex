defmodule AdventOfCode.Day08 do
  import AdventOfCode.Helpers

  @doc """
  iex> split_directions("LRL")
  %{0 => "L", 1 => "R", 2 => "L"}
  """
  def split_directions(directions) do
    directions
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {d, i}, acc ->
      Map.put(acc, i, d)
    end)
  end

  @doc """
  iex> next_direction(%{0 => "L", 1 => "R", 2 => "L"}, 0)
  {"R", 1}

  iex> next_direction(%{0 => "L", 1 => "R", 2 => "L"}, 1)
  {"L", 2}

  iex> next_direction(%{0 => "L", 1 => "R", 2 => "L"}, 2)
  {"L", 0}
  """
  def next_direction(directions, current) do
    new = current + 1

    case Map.get(directions, new) do
      nil ->
        {Map.get(directions, 0), 0}

      direction ->
        {direction, new}
    end
  end

  @doc """
  iex> node_to_map("AAA = (BBB, CCC)")
  %{"AAA" => %{left: "BBB", right: "CCC"}}
  """
  def node_to_map(node) do
    [node, left, right] =
      node
      |> String.replace(~r/[\(\)\s)]/, "")
      |> String.split(["=", ","])

    %{node => %{left: left, right: right}}
  end

  @doc """
  iex> convert_nodes("AAA = (BBB, CCC)\\nBBB = (DDD, EEE)")
  %{
    "AAA" => %{left: "BBB", right: "CCC"},
    "BBB" => %{left: "DDD", right: "EEE"}
  }
  """
  def convert_nodes(nodes) do
    nodes
    |> lines()
    |> Enum.reduce(%{}, fn node, acc ->
      Map.merge(acc, node_to_map(node))
    end)
  end

  @doc """
  iex> move_direction(%{"AAA" => %{left: "BBB", right: "CCC"}}, "AAA", "L")
  "BBB"

  iex> move_direction(%{"AAA" => %{left: "BBB", right: "CCC"}}, "AAA", "R")
  "CCC"
  """
  def move_direction(map, curr, "L"), do: get_in(map, [curr, :left])
  def move_direction(map, curr, "R"), do: get_in(map, [curr, :right])

  @doc """
  iex> find_path(%{0 => "L", 1 => "R"}, %{"AAA" => %{left: "BBB", right: "CCC"}, "BBB" => %{left: "DDD", right: "EEE"}, "EEE" => %{left: "EEE", right: "EEE"}}, "AAA", "EEE")
  ["EEE", "BBB"]
  """
  def find_path(directions, map, current, target) do
    pos = Map.get(directions, 0)
    find_path(directions, pos, 0, map, current, target, [])
  end

  def find_path(_dir, _dv, _dp, _map, current, current, visited), do: visited

  def find_path(directions, d_val, d_pos, map, current, target, visited) do
    current = move_direction(map, current, d_val)
    visited = [current | visited]
    {dir, pos} = next_direction(directions, d_pos)
    find_path(directions, dir, pos, map, current, target, visited)
  end

  def part1(args) do
    [directions, nodes] = String.split(args, "\n\n", trim: true)

    directions = split_directions(directions)
    nodes = convert_nodes(nodes)

    path = find_path(directions, nodes, "AAA", "ZZZ")
    length(path)
  end

  def part2(_args) do
  end
end
