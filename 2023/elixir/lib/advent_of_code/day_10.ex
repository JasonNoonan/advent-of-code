defmodule AdventOfCode.Day10 do
  @moduledoc """
  The pipes are arranged in a two-dimensional grid of tiles:

    | is a vertical pipe connecting north and south.
    - is a horizontal pipe connecting east and west.
    L is a 90-degree bend connecting north and east.
    J is a 90-degree bend connecting north and west.
    7 is a 90-degree bend connecting south and west.
    F is a 90-degree bend connecting south and east.
    . is ground; there is no pipe in this tile.
    S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
  """

  import AdventOfCode.Helpers

  @move_from %{
    "|" => [:north, :south],
    "-" => [:east, :west],
    "L" => [:north, :east],
    "J" => [:west, :north],
    "7" => [:west, :south],
    "F" => [:east, :south],
    "." => [],
    "S" => [:north, :east, :south, :west]
  }

  def delta(:north), do: {0, -1}
  def delta(:south), do: {0, 1}
  def delta(:east), do: {1, 0}
  def delta(:west), do: {-1, 0}

  def from(:north), do: :south
  def from(:south), do: :north
  def from(:east), do: :west
  def from(:west), do: :east

  def move(_map, start, _from, steps, start), do: steps

  def move(map, {x, y} = pos, from, steps, start) do
    symbol = Map.get(map, pos)

    if symbol == "." or is_nil(symbol) do
      nil
    else
      next = Map.get(@move_from, symbol) |> Enum.reject(fn x -> x == from end)

      if length(next) > 1 or length(next) == 0 do
        nil
      else
        next = hd(next)
        {dx, dy} = delta(next)
        move(map, {x + dx, y + dy}, from(next), steps + 1, start)
      end
    end
  end

  def find_loop(map, {x, y} = start) do
    for direction <- [:north, :south, :east, :west] do
      {dx, dy} = delta(direction)
      delta = {x + dx, y + dy}
      target = Map.get(map, delta)
      next = Map.get(@move_from, target)
      from = from(direction)

      next =
        if is_nil(next) do
          nil
        else
          Enum.reject(next, fn x -> x == from end)
        end

      if is_nil(next) or length(next) > 1 or length(next) == 0 do
        nil
      else
        move(map, delta, from, 1, start)
      end
    end
  end

  def find_start(map) do
    Enum.find(map, fn {_pos, val} -> val == "S" end) |> elem(0)
  end

  def part1(args) do
    map =
      args
      |> lines()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        String.graphemes(line)
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {symbol, x}, inner ->
          Map.put(inner, {x, y}, symbol)
        end)
      end)

    start = find_start(map)

    find_loop(map, start)
    |> Enum.uniq()
    |> Enum.reject(fn x -> is_nil(x) end)
    |> hd()
    |> div(2)
  end

  def part2(_args) do
  end
end
