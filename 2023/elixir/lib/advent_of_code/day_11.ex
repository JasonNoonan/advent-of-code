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

    {empty_columns, empty_rows, universe_map}
  end

  def expand(empty, x, multi) do
    thresholds = Enum.filter(empty, fn filter -> x > filter end) |> length

    if thresholds > 0 do
      x + thresholds * multi
    else
      x
    end
  end

  def map_expand({e_col, e_row, universe}, expand_by) do
    for {{x, y}, val} <- universe, reduce: %{} do
      acc ->
        if val == "." do
          acc
        else
          x = expand(e_col, x, expand_by)
          y = expand(e_row, y, expand_by)
          Map.put(acc, {x, y}, val)
        end
    end
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
    args
    |> lines()
    |> Enum.map(&String.graphemes/1)
    |> list_to_map()
    |> find_empty()
    |> map_expand(1)
    |> find_distance()
    |> Enum.sum()
  end

  def part2(args, expand) do
    args
    |> lines()
    |> Enum.map(&String.graphemes/1)
    |> list_to_map()
    |> find_empty()
    |> map_expand(expand - 1)
    |> find_distance()
    |> Enum.sum()
  end
end
