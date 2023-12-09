defmodule AdventOfCode.Day09 do
  import AdventOfCode.Helpers

  def get_diff_list([target | _tail] = history) do
    [
      target
      |> slide()
      |> Enum.map(fn [a, b] -> b - a end)
      | history
    ]
  end

  def reduce_to_zero([], history) do
    get_diff_list(history)
    |> reduce_to_zero(history)
  end

  def reduce_to_zero([diffs | _tail] = history) do
    if Enum.all?(diffs, fn x -> x == 0 end) do
      history
    else
      history
      |> get_diff_list()
      |> reduce_to_zero()
    end
  end

  def part1(args) do
    for line <- lines(args) do
      history =
        line
        |> String.split(" ")
        |> Enum.map(&String.to_integer/1)

      reduce_to_zero([history])
      |> Enum.reduce(0, fn h, acc ->
        List.last(h) + acc
      end)
    end
    |> Enum.sum()
  end

  def part2(_args) do
  end
end
