defmodule AdventOfCode.Day02 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn row, acc ->
      result = get_safe_record(row)

      if is_nil(result) or Map.has_key?(result, :aborted) do
        acc
      else
        [row | acc]
      end
    end)
    |> Enum.count()
  end

  def part2(_args) do
  end

  defp get_safe_record(row) do
    row = String.split(row, " ")

    has_duplicate_chars? =
      row
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.any?(fn freq -> freq > 1 end)

    if has_duplicate_chars? do
      nil
    else
      [head | row] = row
      #
      # init = %{
      #   prev_value: String.to_integer(head),
      #   prev_change: nil
      # }
      #
      # row
      # |> Enum.reduce_while(init, fn i, acc ->
      #   level = String.to_integer(i)
      #   {change, change_value} = get_change(acc.prev_value, level)
      #
      #   if is_nil(acc.prev_change) or
      #        (acc.prev_change == change and change_value >= 1 and change_value <= 3) do
      #     {:cont, %{prev_value: level, prev_change: change}}
      #   else
      #     {:halt, %{aborted: true}}
      #   end
      # end)

      get_safe_level(String.to_integer(head), nil, row)
    end
  end

  defp get_safe_level(_prev_value, _change, []), do: %{}

  defp get_safe_level(prev_value, nil, [i | levels]) do
    level = String.to_integer(i)
    {change, change_value} = get_change(prev_value, level)

    if change_value >= 1 and change_value <= 3 do
      get_safe_level(level, change, levels)
    else
      %{
        aborted: true,
        change: change,
        change_value: change_value,
        prev_value: prev_value,
        current_value: level
      }
    end
  end

  defp get_safe_level(prev_value, prev_change, [i | levels]) do
    level = String.to_integer(i)
    {change, change_value} = get_change(prev_value, level)

    if change == prev_change and (change_value >= 1 and change_value <= 3) do
      get_safe_level(level, change, levels)
    else
      %{
        aborted: true,
        change: change,
        change_value: change_value,
        prev_value: prev_value,
        current_value: level
      }
    end
  end

  defp get_change(l, r) when l > r, do: {:decrease, l - r}
  defp get_change(l, r), do: {:increase, r - l}
end
