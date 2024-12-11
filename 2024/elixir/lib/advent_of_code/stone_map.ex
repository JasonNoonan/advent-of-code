defmodule AdventOfCode.StoneMap do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{stones: %{}} end, name: __MODULE__)
  end

  def init(stones) do
    Agent.update(__MODULE__, fn %{stones: map} ->
      map =
        Enum.reduce(stones, map, fn stone, acc ->
          Map.update(acc, stone, 1, fn x -> x + 1 end)
        end)

      %{stones: map}
    end)
  end

  def blink() do
    Agent.update(__MODULE__, fn %{stones: stones} ->
      stones =
        Enum.reduce(stones, %{}, fn {stone, qty}, acc ->
          case update_stone(stone) do
            {:ok, new} ->
              Map.update(acc, new, qty, fn x -> x + qty end)

            {:split, split} ->
              Enum.reduce(split, acc, fn s, map ->
                Map.update(map, s, qty, fn x -> x + qty end)
              end)
          end
        end)

      %{stones: stones}
    end)
  end

  def get_stones() do
    Agent.get(__MODULE__, fn %{stones: stones} -> dbg(stones) end)
  end

  def get_count() do
    Agent.get(__MODULE__, fn %{stones: stones} ->
      Enum.reduce(stones, 0, fn {_s, qty}, acc -> acc + qty end)
    end)
  end

  defp update_stone(0), do: {:ok, 1}

  defp update_stone(s) do
    chars = Integer.to_string(s) |> String.graphemes()
    count = Enum.count(chars)

    if rem(count, 2) == 0 do
      {:split, split_stone(chars, count)}
    else
      {:ok, s * 2024}
    end
  end

  defp split_stone(stone, count) do
    {left, right} = Enum.split(stone, div(count, 2))

    left = List.to_string(left) |> String.to_integer()

    right =
      Enum.reduce(right, 0, fn s, val ->
        s = String.to_integer(s)

        case {s, val} do
          {0, 0} -> 0
          {x, 0} -> x
          {x, acc} -> acc * 10 + x
        end
      end)

    [left, right]
  end
end
