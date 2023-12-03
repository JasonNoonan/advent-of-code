defmodule AdventOfCode.Day03 do
  alias AdventOfCode.Helpers
  defguard is_string_integer(x) when x in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  # if current target is a number, append to current state list
  # and carry on
  def build_number_range({{num_list, pos_list}, state}, coords, target, _schematic)
      when is_string_integer(target) do
    {{[target | num_list], [coords | pos_list]}, state}
  end

  # if prev state was empty, and current target is a number
  # start building state
  def build_number_range({{}, state}, coords, target, _schematic)
      when is_string_integer(target) do
    {{[target], [coords]}, state}
  end

  # if prev state was building a number
  # and new entry is not a number
  # get current number, store range in map
  # and reset current state
  def build_number_range({{num_list, pos_list}, state}, _coords, _target, schematic)
      when length(num_list) > 0 do
    num = Enum.reverse(num_list) |> List.to_string()
    pos = pos_list |> Enum.reverse()

    if has_adjacent_symbol?(pos_list, schematic) do
      state = Map.put(state, num, pos)
      {{}, state}
    else
      {{}, state}
    end
  end

  # if prev state empty and target is not a number, pass through
  def build_number_range({{}, state}, _coords, _target, _schematic) do
    {{}, state}
  end

  def has_adjacent_symbol?(pos_list, schematic) when is_list(pos_list) do
    for point <- pos_list do
      has_adjacent_symbol?(point, schematic)
      |> Enum.any?(fn {_coord, x} ->
        not is_string_integer(x) and x != "."
      end)
    end
    |> Enum.any?()
  end

  def has_adjacent_symbol?(point, schematic) do
    Helpers.get_adj(schematic, point)
  end

  def get_number_ranges(map) do
    {{{x_min, _}, _}, {{x_max, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
    {{{_, y_min}, _}, {{_, y_max}, _}} = Enum.min_max_by(map, fn {{_, y}, _} -> y end)

    {{}, valid_numbers} =
      for y <- y_min..y_max, x <- x_min..x_max, reduce: {{}, %{}} do
        {curr_range, acc} ->
          value = Map.get(map, {x, y})
          build_number_range({curr_range, acc}, {x, y}, value, map)
      end

    Map.keys(valid_numbers)
  end

  def part1(args) do
    args
    |> Helpers.lines()
    |> Enum.map(fn line ->
      String.codepoints(line)
    end)
    |> Helpers.list_to_map()
    |> get_number_ranges()
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def part2(_args) do
  end
end
