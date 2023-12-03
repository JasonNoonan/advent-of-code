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
    if has_adjacent_symbol?(pos_list, schematic) do
      num = Enum.reverse(num_list) |> List.to_string()
      pos = pos_list |> Enum.reverse()
      {{}, [{num, pos} | state]}
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
      for y <- y_min..y_max, x <- x_min..x_max, reduce: {{}, []} do
        {curr_range, acc} ->
          value = Map.get(map, {x, y})
          build_number_range({curr_range, acc}, {x, y}, value, map)
      end

    valid_numbers
  end

  def get_gear_positions(map) do
    Map.filter(map, fn {_pos, value} ->
      value == "*"
    end)
  end

  def part1(args) do
    args
    |> Helpers.lines()
    |> Enum.map(&String.codepoints/1)
    |> Helpers.list_to_map()
    |> get_number_ranges()
    |> Enum.map(fn {num, _positions} -> String.to_integer(num) end)
    |> Enum.sum()
  end

  def part2(args) do
    map =
      args
      |> Helpers.lines()
      |> Enum.map(&String.codepoints/1)
      |> Helpers.list_to_map()

    num_tuple = get_number_ranges(map)

    for {pos, _gear} <- get_gear_positions(map), reduce: [] do
      acc ->
        neighbors =
          for {pos, _value} <-
                Helpers.get_adj(map, pos)
                |> Map.filter(fn {_pos, x} -> is_string_integer(x) end),
              reduce: [] do
            inner_acc ->
              [{_value, _pos_list} = neighbor] =
                Enum.filter(num_tuple, fn {_num, position} -> pos in position end)

              [neighbor | inner_acc]
          end
          |> Enum.uniq()

        if length(neighbors) == 2 do
          product =
            neighbors
            |> Enum.map(fn {x, _pos} -> String.to_integer(x) end)
            |> Enum.product()

          [product | acc]
        else
          acc
        end
    end
    |> Enum.sum()
  end
end
