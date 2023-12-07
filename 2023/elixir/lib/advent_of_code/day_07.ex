defmodule AdventOfCode.Day07 do
  import AdventOfCode.Helpers

  @card_values ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
               |> Enum.with_index()
               |> Enum.reduce(%{}, fn {card, value}, acc -> Map.put(acc, card, value) end)

  defp get_hand_type([5]), do: 7
  defp get_hand_type([4, 1]), do: 6
  defp get_hand_type([3, 2]), do: 5
  defp get_hand_type([3, 1, 1]), do: 4
  defp get_hand_type([2, 2, 1]), do: 3
  defp get_hand_type([2, 1, 1, 1]), do: 2
  defp get_hand_type([1, 1, 1, 1, 1]), do: 1

  def part1(args) do
    for line <- lines(args) do
      [cards, bid] = String.split(line, " ", trim: true)
      card_list = String.graphemes(cards)
      point_list = Enum.map(card_list, fn x -> Map.get(@card_values, x) end)

      grouped_count =
        Enum.group_by(card_list, fn x -> x end)
        |> Enum.reduce([], fn {_val, occurrences}, acc ->
          [length(occurrences) | acc]
        end)
        |> Enum.sort(:desc)

      type = get_hand_type(grouped_count)
      %{cards: card_list, values: point_list, strength: type, bid: String.to_integer(bid)}
    end
    |> Enum.sort(fn l, r ->
      cond do
        l.strength > r.strength ->
          false

        l.strength < r.strength ->
          true

        true ->
          cond do
            l.values > r.values -> false
            l.values < r.values -> true
            true -> false
          end
      end
    end)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {%{bid: bid}, rank}, acc ->
      acc + bid * (rank + 1)
    end)
  end

  def part2(_args) do
  end
end
