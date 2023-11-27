defmodule AdventOfCode.Day14 do
  ###############
  # pathing functions
  ###############

  defp move_down({sx, sy}, map) do
    # find the nearest obstruction straight down
    case Enum.filter(map, fn {{x, y}, _} -> x == sx and y > sy end) do
      blocks when is_list(blocks) and length(blocks) > 0 ->
        {{x, y}, _material} = Enum.min_by(blocks, fn {{_x, y}, _} -> y end)
        {x, y - 1}

      [] ->
        :end
    end
  end

  defp move_left({sx, sy}, map) do
    case Enum.filter(map, fn {{x, y}, _} -> x == sx - 1 and y == sy + 1 end) do
      [{{_x, _y}, _material}] -> :blocked
      [] -> {sx - 1, sy + 1}
    end
  end

  defp move_right({sx, sy}, map) do
    case Enum.filter(map, fn {{x, y}, _} -> x == sx + 1 and y == sy + 1 end) do
      [{{_x, _y}, _material}] -> :blocked
      [] -> {sx + 1, sy + 1}
    end
  end

  defp try_moving({px, py} = pos, map) do
    case move_left(pos, map) do
      {x, y} ->
        drop({x, y}, map)

      :blocked ->
        case move_right(pos, map) do
          {x, y} ->
            drop({x, y}, map)

          :blocked ->
            case {px, py} do
              {500, 0} ->
                {:end, Map.put(map, {500, 0}, :sand)}

              {px, py} ->
                Map.put(map, {px, py}, :sand)
            end
        end
    end
  end

  defp drop({sx, sy}, map) do
    case move_down({sx, sy}, map) do
      :end ->
        :end

      {x, y} ->
        try_moving({x, y}, map)
    end
  end

  defp emit_sand({sx, sy}, map) do
    case drop({sx, sy}, map) do
      new_map when is_map(new_map) ->
        emit_sand({sx, sy}, new_map)

      :end ->
        map

      {:end, map} ->
        map
    end
  end

  ###############
  # main
  ###############

  def part1(args) do
    map = map_blocks(args)

    emit_sand({500, 0}, map)
    |> count_sand()
  end

  def part2(args) do
    map =
      map_blocks(args)
      |> add_floor()

    emit_sand({500, 0}, map)
    |> count_sand()
  end

  ###############
  # non-critical functions
  ###############

  defp map_blocks(args) do
    args
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce(%{}, fn block, acc ->
      block
      |> String.split(" -> ")
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(acc, fn [first, second], inner_acc ->
        [x1, y1] = String.split(first, ",")
        [x2, y2] = String.split(second, ",")
        Map.merge(inner_acc, map_stones(x1, x2, y1, y2))
      end)
    end)
  end

  defp find_floor(map) do
    {{_x, lowest}, _} = Enum.max_by(map, fn {{_x, y}, _material} -> y end)
    lowest + 2
  end

  defp count_sand(map) do
    map
    |> Enum.filter(fn {{_x, _y}, material} -> material == :sand end)
    |> length()
  end

  defp add_floor(map) do
    {{{x_min, _}, _}, {{x_max, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
    floor = find_floor(map)

    Map.merge(map, map_stones(x_min - floor, x_max + floor, floor, floor))
  end

  defp to_integer(n) when is_integer(n) do
    n
  end

  defp to_integer(n) do
    {n, _} = Integer.parse(n)
    n
  end

  defp map_stones(x, x, y1, y2) do
    x = to_integer(x)
    y1 = to_integer(y1)
    y2 = to_integer(y2)

    Range.new(Enum.max([y1, y2]), Enum.min([y1, y2]))
    |> Enum.reduce(%{}, fn y, acc ->
      Map.put(acc, {x, y}, :stone)
    end)
  end

  defp map_stones(x1, x2, y, y) do
    x1 = to_integer(x1)
    x2 = to_integer(x2)
    y = to_integer(y)

    Range.new(Enum.max([x1, x2]), Enum.min([x1, x2]))
    |> Enum.reduce(%{}, fn x, acc ->
      Map.put(acc, {x, y}, :stone)
    end)
  end
end
