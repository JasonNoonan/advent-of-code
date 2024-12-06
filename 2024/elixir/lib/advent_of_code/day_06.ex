defmodule AdventOfCode.Day06 do
  alias AdventOfCode.Helpers

  defmodule Guard do
    defstruct position: :tuple, facing: :atom, visited: MapSet.new()

    def new(x, y, facing \\ :up) do
      %__MODULE__{
        position: {x, y},
        facing: facing,
        visited: MapSet.new()
      }
    end

    def change_facing(%__MODULE__{facing: :up} = guard), do: %__MODULE__{guard | facing: :right}
    def change_facing(%__MODULE__{facing: :right} = guard), do: %__MODULE__{guard | facing: :down}
    def change_facing(%__MODULE__{facing: :down} = guard), do: %__MODULE__{guard | facing: :left}
    def change_facing(%__MODULE__{facing: :left} = guard), do: %__MODULE__{guard | facing: :up}

    def update_location(%__MODULE__{position: original, visited: visited} = guard, position),
      do: %__MODULE__{guard | position: position, visited: MapSet.put(visited, original)}

    def move(%__MODULE__{} = guard, map, boundaries) do
      if is_target_in_bounds?(guard, boundaries) do
        case get_next_position(guard, map) do
          {_pos, "#"} ->
            guard = change_facing(guard)
            move(guard, map, boundaries)

          {pos, _non_blocker} ->
            guard = update_location(guard, pos)
            move(guard, map, boundaries)
        end
      else
        # yes, this will update the guard into a `nil` position off the map, and that's fine
        pos = get_next_position(guard, map)
        update_location(guard, pos)
      end
    end

    defp is_target_in_bounds?(%__MODULE__{position: {_x, y}, facing: :up}, %{y_min: y}), do: false

    defp is_target_in_bounds?(%__MODULE__{position: {x, _y}, facing: :right}, %{x_max: x}),
      do: false

    defp is_target_in_bounds?(%__MODULE__{position: {_x, y}, facing: :down}, %{y_max: y}),
      do: false

    defp is_target_in_bounds?(%__MODULE__{position: {x, _y}, facing: :left}, %{x_min: x}),
      do: false

    defp is_target_in_bounds?(_guard, _boundaries), do: true

    defp get_next_position(%__MODULE__{position: {x, y}, facing: :up}, map),
      do: {{x, y - 1}, Map.get(map, {x, y - 1})}

    defp get_next_position(%__MODULE__{position: {x, y}, facing: :right}, map),
      do: {{x + 1, y}, Map.get(map, {x + 1, y})}

    defp get_next_position(%__MODULE__{position: {x, y}, facing: :down}, map),
      do: {{x, y + 1}, Map.get(map, {x, y + 1})}

    defp get_next_position(%__MODULE__{position: {x, y}, facing: :left}, map),
      do: {{x - 1, y}, Map.get(map, {x - 1, y})}
  end

  def part1(args) do
    map =
      args
      |> Helpers.lines()
      |> Enum.map(&String.graphemes/1)
      |> Helpers.list_to_map()

    {x, y} = Enum.find_value(map, fn {k, v} -> if v == "^", do: k end)

    boundaries = get_boundaries(map)

    Guard.new(x, y)
    |> Guard.move(map, boundaries)
    |> then(fn x -> MapSet.to_list(x.visited) |> Enum.count() end)
  end

  def part2(_args) do
  end

  defp get_boundaries(map) do
    {{{x_min, _}, _}, {{x_max, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
    {{{_, y_min}, _}, {{_, y_max}, _}} = Enum.min_max_by(map, fn {{_, y}, _} -> y end)

    %{x_min: x_min, x_max: x_max, y_min: y_min, y_max: y_max}
  end
end
