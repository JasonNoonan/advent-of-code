defmodule AdventOfCode.Day02 do
  def impossible?(rounds_list, target) do
    rounds_list
    |> String.split("; ")
    |> Enum.map(fn pull ->
      String.split(pull, ", ")
      |> Enum.map(fn tile ->
        tile
        |> String.split(" ")
        |> Enum.chunk_every(2)
        |> Enum.reject(fn [count, color] ->
          String.to_integer(count) <= Map.get(target, color)
        end)
      end)
    end)
    |> List.flatten()
    |> Enum.any?()
  end

  def part1(args) do
    target = %{"red" => 12, "green" => 13, "blue" => 14}

    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(": ")
      |> Enum.chunk_every(2)
      |> Enum.reduce(
        [],
        fn x, acc ->
          ["Game " <> game_number, rounds_list] = x

          if impossible?(rounds_list, target) do
            acc
          else
            [String.to_integer(game_number) | acc]
          end
        end
      )
    end)
    |> List.flatten()
    |> Enum.sum()
  end
  end
end
