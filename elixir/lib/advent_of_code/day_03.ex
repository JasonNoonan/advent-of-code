defmodule AdventOfCode.Day03 do
  def part1(args) do
    args
    |> split_lines()
    |> Enum.map(&sort_sacks/1)
    |> Enum.sum()
    |> dbg()
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [a, b, c] ->
      a = String.graphemes(a) |> MapSet.new()
      b = String.graphemes(b) |> MapSet.new()
      c = String.graphemes(c) |> MapSet.new()

      badge = MapSet.intersection(a, MapSet.intersection(b, c)) |> Enum.uniq() |> Enum.join()

      get_index_of_char(badge) + 1
    end)
    |> Enum.sum()
    |> dbg()
  end

  def sort_sacks(rucksack) do
    length = String.length(rucksack)
    char_list = String.graphemes(rucksack)

    half = Integer.floor_div(length, 2)
    c1 = Enum.take(char_list, half) |> MapSet.new()
    c2 = Enum.take(char_list, half * -1) |> MapSet.new()
    diff = MapSet.intersection(c1, c2) |> Enum.uniq() |> Enum.join()

    get_index_of_char(diff) + 1
  end

  def split_lines(args) do
    args |> String.split("\n", trim: true)
  end

  def split_characters(args) do
    args |> String.graphemes()
  end

  def get_index_of_char(target) do
    char_list = String.graphemes("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    Enum.find_index(char_list, fn char -> char == target end)
  end
end
