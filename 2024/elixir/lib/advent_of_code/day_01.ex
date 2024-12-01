defmodule AdventOfCode.Day01 do
  def part1(args) do
    {left, right} = get_split_list(args)

    left = Enum.sort(left)
    right = Enum.sort(right)

    Enum.zip_reduce([left, right], [], fn [l, r], acc ->
      [get_distance(l, r) | acc]
    end)
    |> Enum.sum()
  end

  def part2(args) do
    {left, right} = get_split_list(args)

    freq = Enum.frequencies(right)

    Enum.reduce(left, 0, fn i, acc ->
      i * Map.get(freq, i, 0) + acc
    end)
  end

  defp get_distance(l, r) when l > r, do: l - r
  defp get_distance(l, r) when l < r, do: r - l
  defp get_distance(l, r), do: l - r

  defp get_split_list(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], []}, fn row, {left, right} ->
      %{"l" => l, "r" => r} = Regex.named_captures(~r/(?<l>\d+)\s+(?<r>\d+)/, row)
      {[String.to_integer(l) | left], [String.to_integer(r) | right]}
    end)
  end
end
