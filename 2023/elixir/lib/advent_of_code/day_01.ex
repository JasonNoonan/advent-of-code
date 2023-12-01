defmodule AdventOfCode.Day01 do
  def handle_digits(nums) do
    case length(nums) do
      2 ->
        List.to_string(nums) |> String.to_integer()

      1 ->
        first = List.first(nums)
        [first, first] |> List.to_string() |> String.to_integer()

      0 ->
        0

      _else ->
        first = List.first(nums)
        last = List.last(nums)
        [first, last] |> List.to_string() |> String.to_integer()
    end
  end

  def convert_to_number(num) do
    case num do
      "one" -> "1"
      "two" -> "2"
      "three" -> "3"
      "four" -> "4"
      "five" -> "5"
      "six" -> "6"
      "seven" -> "7"
      "eight" -> "8"
      "nine" -> "9"
      other -> other
    end
  end

  def part1(args) do
    for line <- String.split(args, "\n", trim: true), reduce: [] do
      acc ->
        nums =
          Regex.scan(~r/\d/, line)
          |> handle_digits()

        [nums | acc]
    end
    |> Enum.sum()
  end

  def part2(args) do
    for line <- String.split(args, "\n", trim: true), reduce: [] do
      acc ->
        nums =
          Regex.scan(~r/(?=(\d|one|two|three|four|five|six|seven|eight|nine))/, line)
          |> Enum.map(fn [_match, num] -> convert_to_number(num) end)
          |> handle_digits()

        [nums | acc]
    end
    |> Enum.sum()
  end
end
