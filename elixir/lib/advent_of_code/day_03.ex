defmodule AdventOfCode.Day03 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn rucksack, acc ->
      length = String.length(rucksack)
      half = Integer.floor_div(length, 2)
      {c1, c2} = String.split_at(rucksack, half)
      diff = MapSet.intersection(to_mapset(c1), to_mapset(c2)) |> Enum.uniq() |> to_string()

      [get_index_of_char(diff) | acc]
    end)
    |> Enum.sum()
    |> dbg()
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.reduce([], fn [a, b, c], acc ->
      badge =
        MapSet.intersection(to_mapset(a), MapSet.intersection(to_mapset(b), to_mapset(c)))
        |> Enum.uniq()
        |> to_string()

      [get_index_of_char(badge) | acc]
    end)
    |> Enum.sum()
  end

  def split_lines(args) do
    args |> String.split("\n", trim: true)
  end

  def to_mapset(string) do
    string |> String.to_charlist() |> MapSet.new()
  end

  def get_index_of_char(target) do
    [char_list, _] = String.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", target)
    String.length(char_list) + 1
  end
end
