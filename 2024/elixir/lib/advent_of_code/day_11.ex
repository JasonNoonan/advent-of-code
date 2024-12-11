defmodule AdventOfCode.Day11 do
  defmodule Blink do
    use Agent

    alias Sourceror.Zipper

    def start_link() do
      Agent.start_link(fn -> %{stones: []} end, name: __MODULE__)
    end

    def initialize(stones) do
      Agent.update(__MODULE__, fn state ->
        %{state | stones: Zipper.zip(stones)}
      end)
    end

    def step() do
      Agent.update(__MODULE__, fn %{stones: stones} = state ->
        stones =
          Zipper.traverse_while(stones, fn
            %Zipper{node: s} = zipper when is_integer(s) ->
              case update_stone(s) do
                {:ok, stone} ->
                  {:cont, Zipper.update(zipper, fn _zip -> stone end)}

                {:split, stone} ->
                  {:skip, Zipper.update(zipper, fn _zip -> stone end)}
              end

            zipper ->
              {:cont, zipper}
          end)

        %{state | stones: stones}
      end)
    end

    def get_stones() do
      Agent.get(__MODULE__, fn %{stones: stones} -> Zipper.node(stones) end)
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

  def part1(args) do
    Blink.start_link()

    args
    |> String.split(["\n", " "], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Blink.initialize()

    for _x <- 1..25 do
      Blink.step()
    end

    Blink.get_stones() |> List.flatten() |> Enum.count()
  end

  def part2(_args) do
  end
end
