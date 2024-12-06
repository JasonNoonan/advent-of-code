defmodule AdventOfCode.Day06 do
  alias AdventOfCode.Helpers

  defmodule Guard do
    defstruct position: :tuple,
              facing: :atom,
              state: :atom,
              visited: MapSet.new(),
              visited_with_facing: MapSet.new()

    def new(x, y, facing \\ :up) do
      %__MODULE__{
        position: {x, y},
        facing: facing,
        state: :searching,
        visited: MapSet.new(),
        visited_with_facing: MapSet.new()
      }
    end

    def change_facing(%__MODULE__{facing: :up} = guard), do: %__MODULE__{guard | facing: :right}
    def change_facing(%__MODULE__{facing: :right} = guard), do: %__MODULE__{guard | facing: :down}
    def change_facing(%__MODULE__{facing: :down} = guard), do: %__MODULE__{guard | facing: :left}
    def change_facing(%__MODULE__{facing: :left} = guard), do: %__MODULE__{guard | facing: :up}

    def update_location(
          %__MODULE__{
            position: original,
            facing: facing,
            visited: visited,
            visited_with_facing: visited_with_facing
          } = guard,
          position
        ),
        do: %__MODULE__{
          guard
          | position: position,
            visited: MapSet.put(visited, original),
            visited_with_facing: MapSet.put(visited_with_facing, {original, facing})
        }

    def leave_map(%__MODULE__{position: original, visited: visited} = guard, position),
      do: %__MODULE__{
        guard
        | position: position,
          state: :exited,
          visited: MapSet.put(visited, original)
      }

    def enter_loop_state(%__MODULE__{} = guard), do: %__MODULE__{guard | state: :looping}

    def move(%__MODULE__{} = guard, map, boundaries, detect_loop? \\ false) do
      if detect_loop? and already_traversed?(guard) do
        enter_loop_state(guard)
      else
        if is_target_in_bounds?(guard, boundaries) do
          case get_next_position(guard, map) do
            {_pos, "#"} ->
              guard = change_facing(guard)
              move(guard, map, boundaries, detect_loop?)

            {pos, _non_blocker} ->
              guard = update_location(guard, pos)
              move(guard, map, boundaries, detect_loop?)
          end
        else
          # yes, this will update the guard into a `nil` position off the map, and that's fine
          pos = get_next_position(guard, map)
          leave_map(guard, pos)
        end
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

    defp already_traversed?(%__MODULE__{
           position: pos,
           facing: facing,
           visited_with_facing: visited
         }),
         do: MapSet.member?(visited, {pos, facing})
  end

  def part1(args) do
    {map, {x, y}, boundaries} = parse_map(args)

    run_map(x, y, map, boundaries, false)
    |> then(fn x -> MapSet.to_list(x.visited) |> Enum.count() end)
  end

  def part2(args) do
    {map, {x, y}, boundaries} = parse_map(args)

    guard = run_map(x, y, map, boundaries, false)

    Enum.reduce(guard.visited, 0, fn {path_x, path_y}, acc ->
      map = replace_symbol(path_x, path_y, map)

      case run_map(x, y, map, boundaries, true) do
        %Guard{state: :looping} ->
          acc + 1

        %Guard{state: :exited} ->
          acc
      end
    end)
  end

  defp get_boundaries(map) do
    {{{x_min, _}, _}, {{x_max, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
    {{{_, y_min}, _}, {{_, y_max}, _}} = Enum.min_max_by(map, fn {{_, y}, _} -> y end)

    %{x_min: x_min, x_max: x_max, y_min: y_min, y_max: y_max}
  end

  defp parse_map(args) do
    map =
      args
      |> Helpers.lines()
      |> Enum.map(&String.graphemes/1)
      |> Helpers.list_to_map()

    {x, y} = Enum.find_value(map, fn {k, v} -> if v == "^", do: k end)

    boundaries = get_boundaries(map)

    {map, {x, y}, boundaries}
  end

  defp run_map(x, y, map, boundaries, detect_loops) do
    Guard.new(x, y)
    |> Guard.move(map, boundaries, detect_loops)
  end

  defp replace_symbol(x, y, map) do
    if Map.get(map, {x, y}) != "^" do
      Map.put(map, {x, y}, "#")
    else
      map
    end
  end
end
