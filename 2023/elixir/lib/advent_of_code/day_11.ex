defmodule AdventOfCode.Day11 do
  import AdventOfCode.Helpers

  def find_empty(universe_map) do
    {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(universe_map, fn {{x, _}, _} -> x end)
    {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(universe_map, fn {{_, y}, _} -> y end)

    empty_columns =
      for x <- min_x..max_x, reduce: [] do
        acc ->
          column = Enum.filter(universe_map, fn {{col, _y}, _} -> col == x end)

          if Enum.all?(column, fn {{_, _}, val} -> val == "." end) do
            [x | acc]
          else
            acc
          end
      end

    empty_rows =
      for y <- min_y..max_y, reduce: [] do
        acc ->
          row = Enum.filter(universe_map, fn {{_x, row}, _} -> row == y end)

          if Enum.all?(row, fn {{_, _}, val} -> val == "." end) do
            [y | acc]
          else
            acc
          end
      end

    {empty_columns, empty_rows}
  end

  def map_expand({e_col, e_row}, universe_list) do
    universe_list
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, i}, acc ->
      new_row =
        row
        |> Enum.with_index()
        |> Enum.reduce([], fn {x, j}, inner ->
          if j in e_col do
            [x | [x | inner]]
          else
            [x | inner]
          end
        end)
        |> Enum.reverse()

      if i in e_row do
        [new_row | [new_row | acc]]
      else
        [new_row | acc]
      end
    end)
    |> Enum.reverse()
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def find_distance(map) do
    positions =
      Enum.filter(map, fn {{_x, _y}, val} -> val == "#" end)
      |> Enum.map(fn {{_, _} = pos, _val} -> pos end)

    for pos <- positions, reduce: %{} do
      acc ->
        exclusive = Enum.reject(positions, fn xy -> pos == xy end)

        for source <- exclusive, reduce: acc do
          inner ->
            {low, high} =
              if source > pos do
                {pos, source}
              else
                {source, pos}
              end

            if Map.has_key?(inner, {low, high}) do
              inner
            else
              Map.put(inner, {low, high}, manhattan_distance(low, high))
            end
        end
    end
    |> Map.values()
  end

  def part1(args) do
    universe_list =
      args
      |> lines()
      |> Enum.map(&String.graphemes/1)

    universe_map =
      universe_list
      |> list_to_map()

    expanded_map =
      find_empty(universe_map)
      |> map_expand(universe_list)
      |> list_to_map()

    find_distance(expanded_map)
    |> Enum.sum()
  end

  def part2(_args) do
  end
end
