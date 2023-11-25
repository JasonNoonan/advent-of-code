defmodule AdventOfCode.Day14 do
  @doc """
    iex> AdventOfCode.Day14.part1("498,4 -> 498,6 -> 496,6\\n503,4 -> 502,4 -> 502,9 -> 494,9")
    5
  """
  defp map_stones(x, x, y1, y2) do
    {x, _} = Integer.parse(x)
    {y1, _} = Integer.parse(y1)
    {y2, _} = Integer.parse(y2)

    Range.new(Enum.max([y1, y2]), Enum.min([y1, y2]))
    |> Enum.map(fn y ->
      {x, y, :stone}
    end)
  end

  defp map_stones(x1, x2, y, y) do
    {x1, _} = Integer.parse(x1)
    {x2, _} = Integer.parse(x2)
    {y, _} = Integer.parse(y)

    Range.new(Enum.max([x1, x2]), Enum.min([x1, x2]))
    |> Enum.map(fn x ->
      {x, y, :stone}
    end)
  end

  defp move_down({sx, sy}, map) do
    # find the nearest obstruction straight down
    case Enum.filter(map, fn {x, y, _} -> x == sx and y > sy end) do
      blocks when is_list(blocks) and length(blocks) > 0 ->
        {x, y, _material} = Enum.min_by(blocks, fn {_x, y, _} -> y end)
        {x, y - 1}

      [] ->
        :end
    end
  end

  defp move_left({sx, sy}, map) do
    case Enum.filter(map, fn {x, y, _} -> x == sx - 1 and y == sy + 1 end) do
      [{_x, _y, _material}] -> :blocked
      [] -> {sx - 1, sy + 1}
    end
  end

  defp move_right({sx, sy}, map) do
    case Enum.filter(map, fn {x, y, _} -> x == sx + 1 and y == sy + 1 end) do
      [{_x, _y, _material}] -> :blocked
      [] -> {sx + 1, sy + 1}
    end
  end

  defp try_moving({px, py} = pos, map) do
    case move_left(pos, map) do
      {x, y} ->
        drop({x, y}, map)

      :blocked ->
        case move_right(pos, map) do
          {x, y} -> drop({x, y}, map)
          :blocked -> [{px, py, :sand} | map]
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
      new_map when is_list(new_map) ->
        emit_sand({sx, sy}, new_map)

      :end ->
        map
    end
  end

  defp map_blocks(args) do
    args
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn block ->
      block
      |> String.split(" -> ")
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [first, second] ->
        [x1, y1] = String.split(first, ",")
        [x2, y2] = String.split(second, ",")
        map_stones(x1, x2, y1, y2)
      end)
    end)
    |> List.flatten()
    |> Enum.uniq()
  end

  def part1(args) do
    map = map_blocks(args)

    emit_sand({500, 0}, map)
    |> Enum.filter(fn {_x, _y, material} -> material == :sand end)
    |> length()
  end

  def part2(_args) do
  end
end
