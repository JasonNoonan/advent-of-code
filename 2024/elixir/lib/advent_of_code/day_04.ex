defmodule AdventOfCode.Day04 do
  alias AdventOfCode.Helpers

  def part1(args) do
    puzzle = map_puzzle(args)

    map = Helpers.list_to_map(puzzle)
    found = MapSet.new()

    puzzle
    |> Enum.with_index()
    |> Enum.reduce(found, fn {row, y}, outer_acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(outer_acc, fn {_char, x}, inner_acc ->
        try_solve(x, y, map, inner_acc)
      end)
    end)
    |> MapSet.to_list()
    |> Enum.count()
  end

  def part2(args) do
    puzzle = map_puzzle(args)

    map = Helpers.list_to_map(puzzle)

    puzzle
    |> Enum.with_index()
    |> Enum.reduce(0, fn {row, y}, outer_acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(outer_acc, fn {char, x}, inner_acc ->
        if char == "A" do
          if solve_part_2(x, y, map) do
            inner_acc + 1
          else
            inner_acc
          end
        else
          inner_acc
        end
      end)
    end)
  end

  defp map_puzzle(args) do
    args
    |> Helpers.lines()
    |> Enum.map(&String.graphemes/1)
  end

  ### Part 1

  defp try_solve(x, y, map, found) do
    x_right = [x, x + 1, x + 2, x + 3]
    x_left = [x, x - 1, x - 2, x - 3]
    x_up = [x, x, x, x]
    x_down = [x, x, x, x]

    y_right = [y, y, y, y]
    y_left = [y, y, y, y]
    y_up = [y, y - 1, y - 2, y - 3]
    y_down = [y, y + 1, y + 2, y + 3]

    [
      solve(x_right, y_right, map),
      solve(x_left, y_left, map),
      solve(x_up, y_up, map),
      solve(x_down, y_down, map),
      solve(x_right, y_up, map),
      solve(x_right, y_down, map),
      solve(x_left, y_up, map),
      solve(x_left, y_down, map)
    ]
    |> Enum.reduce(found, fn
      {:ok, coord_list}, acc ->
        MapSet.put(acc, coord_list)

      {:error, :xmas_not_found}, acc ->
        acc
    end)
  end

  defp solve(xs, ys, map) do
    {result, coord_list} =
      Enum.zip_reduce([xs, ys], {[], []}, fn [x, y], {char_list, coord_list} ->
        val = Map.get(map, {x, y})
        coord_list = [{x, y} | coord_list]
        if is_nil(val), do: {char_list, coord_list}, else: {[val | char_list], coord_list}
      end)

    string_result = List.to_string(result)

    reverse_result =
      result
      |> Enum.reverse()
      |> List.to_string()

    if string_result == "XMAS" or reverse_result == "XMAS" do
      coord_list = Enum.sort(coord_list)
      {:ok, coord_list}
    else
      {:error, :xmas_not_found}
    end
  end

  ### Part 2

  defp solve_part_2(x, y, map) do
    arm_1 =
      [
        {x - 1, y - 1},
        {x, y},
        {x + 1, y + 1}
      ]

    arm_2 = [
      {x + 1, y - 1},
      {x, y},
      {x - 1, y + 1}
    ]

    [
      solve_arm(arm_1, map) |> live_mas(),
      solve_arm(arm_2, map) |> live_mas()
    ]
    |> Enum.all?()
  end

  defp solve_arm(coords, map) do
    Enum.reduce(coords, [], fn xy, acc ->
      char = Map.get(map, xy)

      if is_nil(char) do
        acc
      else
        [char | acc]
      end
    end)
  end

  defp live_mas(arm) do
    result =
      arm
      |> List.to_string()

    result == "MAS" or result == "SAM"
  end

  defp print_map(map, output) do
    # had to bastardize Cody's print_map to work with "should only print if coords are in output"
    # instead of based on the contents of the map's values

    {{{x_min, _}, _}, {{x_max, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
    {{{_, y_min}, _}, {{_, y_max}, _}} = Enum.min_max_by(map, fn {{_, y}, _} -> y end)

    IO.write("\n")

    Enum.each(y_min..y_max, fn y ->
      Enum.each(x_min..x_max, fn x ->
        data = if MapSet.member?(output, {x, y}), do: Map.get(map, {x, y}), else: "."
        IO.write(data)
      end)

      IO.write("\n")
    end)
  end
end
