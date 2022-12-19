defmodule AdventOfCode.Day18 do
  def parse(args) do
    {x_map, y_map, z_map, coords} =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce({%{}, %{}, %{}, []}, fn cube, {x_map, y_map, z_map, coords} ->
        [x, y, z] = String.split(cube, ",") |> Enum.map(&String.to_integer/1)
        x_map = Map.update(x_map, x, [{y, z}], fn curr -> [{y, z} | curr] end)
        y_map = Map.update(y_map, y, [{x, z}], fn curr -> [{x, z} | curr] end)
        z_map = Map.update(z_map, z, [{x, y}], fn curr -> [{x, y} | curr] end)
        coords = [{x, y, z} | coords]
        {x_map, y_map, z_map, coords}
      end)

    coords = Enum.reverse(coords)
    {x_map, y_map, z_map, coords}
  end

  def neighbor_at?(coords, index, map) do
    {index, coords, map}

    at_index = Map.get(map, index)

    if is_nil(at_index),
      do: 1,
      else:
        (
          filter = Enum.filter(at_index, fn coordinates -> coordinates == coords end)
          if Enum.empty?(filter), do: 1, else: 0
        )
  end

  def check_neighbors({x, y, z}, x_map, y_map, z_map) do
    [
      {x + 1, y, z, x_map},
      {x - 1, y, z, x_map},
      {y + 1, x, z, y_map},
      {y - 1, x, z, y_map},
      {z + 1, x, y, z_map},
      {z - 1, x, y, z_map}
    ]
    |> Enum.reduce(0, fn {index, a, b, map}, acc ->
      acc + neighbor_at?({a, b}, index, map)
    end)
  end

  def part1(args) do
    {x_map, y_map, z_map, coords} = parse(args)

    for cube <- coords, reduce: 0 do
      acc ->
        acc + check_neighbors(cube, x_map, y_map, z_map)
    end
  end

  def part2(_args) do
  end
end
