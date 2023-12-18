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

  def find_area(points) do
    shifted = Enum.slide(points, 0, -1)

    points =
      Enum.zip_with(points, shifted, fn {x, y}, {xn, yn} ->
        {x * yn, y * xn}
      end)

    for {a, b} <- points, reduce: 0 do
      area ->
        area
        |> Kernel.+(a)
        |> Kernel.-(b)
    end
    |> abs()
    |> Kernel.*(0.5)
    |> dbg
  end

  def picks_theorem(area, length) do
    area + length / 2 + 1
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
    |> find_area()
    |> picks_theorem(length)
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
    |> find_area()
    |> picks_theorem(length)
  end
end
