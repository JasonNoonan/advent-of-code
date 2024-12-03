defmodule AdventOfCode.Day03 do
  def part1(args) do
    ~r/mul\(\d{1,3},\d{1,3}\)/
    |> Regex.scan(args)
    |> Enum.reduce(0, fn [operation], acc ->
      [x, y] = get_operation_terms(operation)

      x * y + acc
    end)
  end

  def part2(args) do
    ~r/mul\(\d{1,3},\d{1,3}\)|don't\(\)|do\(\)/
    |> Regex.scan(args)
    |> Enum.reduce(%{value: 0, ignore: false}, fn [operation], acc ->
      [op | _terms] = String.split(operation, "(")

      case op do
        "mul" ->
          if not acc.ignore do
            [x, y] = get_operation_terms(operation)

            Map.update!(acc, :value, fn acc -> x * y + acc end)
          else
            acc
          end

        "do" ->
          Map.update!(acc, :ignore, fn _acc -> false end)

        "don't" ->
          Map.update!(acc, :ignore, fn _acc -> true end)
      end
    end)
    |> then(fn x -> x.value end)
  end

  defp get_operation_terms(operation) do
    operation = String.replace(operation, "mul(", "")
    operation = String.replace(operation, ")", "")
    String.split(operation, ",") |> Enum.map(&String.to_integer/1)
  end
end
