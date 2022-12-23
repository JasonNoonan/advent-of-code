defmodule AdventOfCode.Day20 do
  def parse(args, mult \\ 1) do
    String.split(args, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {bit, i} ->
      n = String.to_integer(bit)
      %{val: n * mult, index: i}
    end)
  end

  def mix(target, orig) do
    for x <- orig, reduce: target do
      list ->
        slider(list, x)
    end
  end

  def find_grove(list) do
    index = Enum.find_index(list, fn target -> target == 0 end) |> dbg

    for n <- [1000, 2000, 3000], reduce: 0 do
      sum ->
        sum +
          if length(list) > index + n,
            do: Enum.at(list, index + n),
            else: Enum.at(list, rem(index + n, length(list)))
    end
  end

  def slider(list, target = %{val: n, index: _}) do
    current_pos = Enum.find_index(list, fn iter -> iter == target end)
    new_pos = rem(n + current_pos, length(list) - 1)

    if n < 0,
      do: Enum.slide(list, current_pos, new_pos - 1),
      else: Enum.slide(list, current_pos, new_pos)
  end

  def part1(args) do
    orig = parse(args)

    mix(orig, orig)
    |> Enum.map(fn %{val: n, index: _} -> n end)
    |> find_grove()
  end

  def part2(args) do
    orig = parse(args, 811_589_153)

    for _ <- 1..10, reduce: orig do
      list ->
        mix(list, orig)
    end
    |> Enum.map(fn %{val: n, index: _} -> n end)
    |> find_grove()
  end
end
