defmodule AdventOfCode.Day18 do
  import AdventOfCode.Helpers

  def expand_points({x, y}, {:down, distance}) do
    {x, y + distance}
  end

  def expand_points({x, y}, {:up, distance}) do
    {x, y - distance}
  end

  def expand_points({x, y}, {:left, distance}) do
    {x - distance, y}
  end

  def expand_points({x, y}, {:right, distance}) do
    {x + distance, y}
  end

  def part1(args) do
    runs =
      args
      |> lines()
      |> Enum.map(fn line ->
        [dir, dist, _color] = String.split(line, " ")

        dir =
          case dir do
            "D" -> :down
            "U" -> :up
            "L" -> :left
            "R" -> :right
          end

        {dir, String.to_integer(dist)}
      end)

    length =
      Enum.reduce(runs, 0, fn {_dir, dist}, acc ->
        acc + dist
      end)

    {_pos, points} =
      Enum.reduce(runs, {{0, 0}, []}, fn run, {last_pos, points} ->
        points_over_run = expand_points(last_pos, run)
        {points_over_run, [points_over_run | points]}
      end)

    points
    |> Enum.reverse()
    |> List.flatten()
    |> shoelace_algo()
    |> picks_theorem(length, :full)
  end

  def part2(args) do
    runs =
      args
      |> lines()
      |> Enum.map(fn line ->
        [_dir, _dist, color] = String.split(line, " ")

        color = String.replace(color, ["(", "#", ")"], "") |> String.graphemes()

        dist = Enum.take(color, 5) |> List.to_string() |> String.to_integer(16)

        dir =
          case List.last(color) do
            "0" -> :right
            "1" -> :down
            "2" -> :left
            "3" -> :up
          end

        {dir, dist}
      end)

    length =
      Enum.reduce(runs, 0, fn {_dir, dist}, acc ->
        acc + dist
      end)

    {_pos, points} =
      Enum.reduce(runs, {{0, 0}, []}, fn run, {last_pos, points} ->
        points_over_run = expand_points(last_pos, run)
        {points_over_run, [points_over_run | points]}
      end)

    points
    |> Enum.reverse()
    |> List.flatten()
    |> shoelace_algo()
    |> picks_theorem(length, :full)
  end
end
