defmodule AdventOfCode.Day16 do
  import AdventOfCode.Helpers

  def get_next(map, {x, y}, dir, acc) do
    {dx, dy} =
      delta =
      case dir do
        :right -> {x + 1, y}
        :left -> {x - 1, y}
        :up -> {x, y - 1}
        :down -> {x, y + 1}
      end

    sym = Map.get(map, delta)

    if is_nil(sym) or MapSet.member?(acc, {dx, dy, dir}) do
      :stop
    else
      {:cont, sym, delta}
    end
  end

  def handle_symbol(map, {x, y} = pos, dir, "\\", acc) do
    new_dir =
      case dir do
        :right -> :down
        :left -> :up
        :up -> :left
        :down -> :right
      end

    emit_beam(map, pos, new_dir, MapSet.put(acc, {x, y, dir}))
  end

  def handle_symbol(map, {x, y} = pos, dir, "/", acc) do
    new_dir =
      case dir do
        :right -> :up
        :left -> :down
        :up -> :right
        :down -> :left
      end

    emit_beam(map, pos, new_dir, MapSet.put(acc, {x, y, dir}))
  end

  def handle_symbol(map, {x, y} = pos, dir, "-", acc) do
    new_dir =
      case dir do
        :up -> [:right, :left]
        :down -> [:right, :left]
        _ -> [dir]
      end

    for d <- new_dir, reduce: acc do
      acc ->
        emit_beam(map, pos, d, MapSet.put(acc, {x, y, dir}))
    end
  end

  def handle_symbol(map, {x, y} = pos, dir, "|", acc) do
    new_dir =
      case dir do
        :right -> [:up, :down]
        :left -> [:up, :down]
        _ -> [dir]
      end

    for d <- new_dir, reduce: acc do
      acc ->
        emit_beam(map, pos, d, MapSet.put(acc, {x, y, dir}))
    end
  end

  def emit_beam(map, {x, y} = pos, dir, acc) do
    case get_next(map, pos, dir, acc) do
      :stop ->
        MapSet.put(acc, {x, y, dir})

      {:cont, sym, next} ->
        case sym do
          "." -> emit_beam(map, next, dir, MapSet.put(acc, {x, y, dir}))
          s -> handle_symbol(map, next, dir, s, MapSet.put(acc, {x, y, dir}))
        end
    end
  end

  def part1(args) do
    args
    |> lines()
    |> Enum.map(&String.graphemes/1)
    |> list_to_map()
    |> print_map(display: fn x -> x end)
    |> emit_beam({-1, 0}, :right, MapSet.new())
    |> Enum.reduce(MapSet.new(), fn {x, y, _val}, acc ->
      if {x, y} == {-1, 0} do
        acc
      else
        MapSet.put(acc, {x, y})
      end
    end)
    |> MapSet.to_list()
    |> length()
  end

  def part2(_args) do
  end
end
