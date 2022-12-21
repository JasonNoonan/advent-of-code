defmodule AdventOfCode.Day20 do
  def slider(list, target = %{val: n, index: _}) do
    current_pos = Enum.find_index(list, fn iter -> iter == target end)
    new_pos = rem(n + current_pos, length(list) - 1)

    if n < 0,
      do: Enum.slide(list, current_pos, new_pos - 1),
      else: Enum.slide(list, current_pos, new_pos)
  end

  def part1(args) do
    orig =
      String.split(args, "\n", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {bit, i} ->
        n = String.to_integer(bit)
        %{val: n, index: i}
      end)

    mixed =
      for x <- orig, reduce: orig do
        list ->
          slider(list, x)
      end
      |> Enum.map(fn %{val: n, index: _} -> n end)

    index = Enum.find_index(mixed, fn target -> target == 0 end) |> dbg

    for n <- [1000, 2000, 3000], reduce: 0 do
      sum ->
        sum +
          if length(mixed) > index + n,
            do: Enum.at(mixed, index + n),
            else: Enum.at(mixed, rem(index + n, length(mixed)))
    end
  end

  def part2(_args) do
  end
end
