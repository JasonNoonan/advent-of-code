defmodule AdventOfCode.Day02 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn row, acc ->
      row = String.split(row, " ")
      result = get_safe_record(row, true, 0)

      if is_nil(result) or Map.has_key?(result, :aborted) do
        acc
      else
        [row | acc]
      end
    end)
    |> Enum.count()
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn row, acc ->
      row = String.split(row, " ")

      if Map.has_key?(get_safe_record(row, false, 1), :aborted) do
        record_index = Enum.with_index(row)

        result =
          Enum.reduce_while(record_index, [], fn {_level, index}, inner_acc ->
            row = List.delete_at(row, index)

            if Map.has_key?(get_safe_record(row, false, 0), :aborted) do
              {:cont, inner_acc}
            else
              # don't actually care if we have a list of multiple, any row will do
              {:halt, row}
            end
          end)

        [result | acc]
      else
        [row | acc]
      end
    end)
    |> Enum.reject(fn list -> length(list) == 0 end)
    |> Enum.count()
  end

  defp get_safe_record(row, remove_duplicates?, error_tolerance) do
    has_duplicate_chars? =
      if remove_duplicates? do
        row
        |> Enum.frequencies()
        |> Map.values()
        |> Enum.any?(fn freq -> freq > 1 end)
      else
        false
      end

    if has_duplicate_chars? do
      nil
    else
      [head | row] = row

      get_safe_level(String.to_integer(head), nil, row, 0, error_tolerance)
    end
  end

  defp get_safe_level(_prev_value, _change, [], _errors, _error_tolerance), do: %{}

  defp get_safe_level(prev_value, nil, [i | levels], errors, error_tolerance) do
    level = String.to_integer(i)
    {change, change_value} = get_change(prev_value, level)

    {errors, level, change} =
      if change_value >= 1 and change_value <= 3,
        do: {errors, level, change},
        else: {errors + 1, level, nil}

    if errors <= error_tolerance do
      get_safe_level(level, change, levels, errors, error_tolerance)
    else
      %{
        aborted: true,
        change: change,
        change_value: change_value,
        prev_value: prev_value,
        current_value: level,
        errors: errors,
        error_tolerance: error_tolerance
      }
    end
  end

  defp get_safe_level(prev_value, prev_change, [i | levels], errors, error_tolerance) do
    level = String.to_integer(i)
    {change, change_value} = get_change(prev_value, level)

    {errors, level, change} =
      if change == prev_change and (change_value >= 1 and change_value <= 3),
        do: {errors, level, change},
        else: {errors + 1, prev_value, prev_change}

    if errors <= error_tolerance do
      get_safe_level(level, change, levels, errors, error_tolerance)
    else
      %{
        aborted: true,
        change: change,
        change_value: change_value,
        prev_value: prev_value,
        current_value: level,
        errors: errors,
        error_tolerance: error_tolerance
      }
    end
  end

  defp get_change(l, r) when l > r, do: {:decrease, l - r}
  defp get_change(l, r) when l == r, do: {:eq, l - r}
  defp get_change(l, r), do: {:increase, r - l}
end
