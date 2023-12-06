defmodule AdventOfCode.Day06 do
  import AdventOfCode.Helpers

  def calculate_possible_distances(time, distance) do
    for t <- 1..(time - 1) do
      (time - t) * t > distance
    end
    |> Enum.filter(& &1)
  end

  def part1(args) do
    for line <- lines(args) do
      [_header | rest] = String.split(line, " ", trim: true)

      Enum.map(rest, &String.to_integer/1)
    end
    |> Enum.zip_reduce([], fn elements, acc -> [List.to_tuple(elements) | acc] end)
    |> Enum.reduce([], fn {time, distance}, acc ->
      [length(calculate_possible_distances(time, distance)) | acc]
    end)
    |> Enum.product()
  end

  def part2(args) do
    for line <- lines(args) do
      [_header | rest] = String.replace(line, " ", "") |> String.split(":")

      Enum.map(rest, &String.to_integer/1)
    end
    |> Enum.zip_reduce([], fn elements, acc -> [List.to_tuple(elements) | acc] end)
    |> Enum.map(fn {time, distance} -> calculate_possible_distances(time, distance) end)
    |> List.flatten()
    |> length()
  end
end
