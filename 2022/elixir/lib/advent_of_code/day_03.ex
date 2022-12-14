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
      IO.puts('just a test')
      a = String.graphemes(a)
      b = String.graphemes(b)
      c = String.graphemes(c)

      uniquely_a_from_b = a -- b
      shared_in_a_and_b = a -- uniquely_a_from_b

      uniquely_c = c -- shared_in_a_and_b
      badge = (c -- uniquely_c) |> Enum.uniq() |> Enum.join()
      get_index_of_char(badge) + 1
    end)
    |> Enum.sum()
    |> dbg()
  end

  def sort_sacks(rucksack) do
    length = String.length(rucksack)
    char_list = split_characters(rucksack)

    half = Integer.floor_div(length, 2)
    c1 = Enum.take(char_list, half)
    c2 = Enum.take(char_list, half * -1)

    not_in_list_2 = c1 -- c2
    diff = (c1 -- not_in_list_2) |> Enum.uniq() |> Enum.join()
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
