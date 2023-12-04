defmodule AdventOfCode.Day04 do
  import AdventOfCode.Helpers

  def score_card(nums) when nums > 1 do
    Enum.reduce(2..nums, 1, fn _v, acc ->
      acc * 2
    end)
  end

  def score_card(nums) when nums == 1, do: 1
  def score_card(_nums), do: 0

  def spread_points([multi | tail], 0) do
    multi = multi + 1

    {tail, multi}
  end

  def spread_points([], 0) do
    {[], 1}
  end

  def spread_points([multi | tail], points) do
    multi = multi + 1

    knockon =
      for _ <- 1..points do
        multi
      end

    adjusted = merge_lists(knockon, tail)
    {adjusted, multi}
  end

  def spread_points([], points) do
    knockon =
      for _ <- 1..points do
        1
      end

    {knockon, 1}
  end

  def merge_lists(left, right) when length(left) >= length(right) do
    merge(left, right)
  end

  def merge_lists(left, right) when length(left) < length(right) do
    merge(right, left)
  end

  def merge(left, right) do
    for {x, index} <- Enum.with_index(left), reduce: [] do
      acc ->
        case Enum.fetch(right, index) do
          {:ok, value} ->
            [x + value | acc]

          :error ->
            [x | acc]
        end
    end
    |> Enum.reverse()
  end

  def get_number_set(list) do
    list
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.into(MapSet.new())
  end

  def part1(args) do
    args
    |> lines()
    |> Enum.reduce(0, fn line, acc ->
      [_card, winning, mine] = String.split(line, [":", "|"], trim: true)
      winning = get_number_set(winning)
      mine = get_number_set(mine)

      winners = MapSet.intersection(winning, mine) |> MapSet.to_list()

      acc + score_card(length(winners))
    end)
  end

  def part2(args) do
    args
    |> lines()
    |> Enum.reduce({[], 0}, fn line, {spread, acc} ->
      [_card, winning, mine] = String.split(line, [":", "|"], trim: true)
      winning = get_number_set(winning)
      mine = get_number_set(mine)

      winners = MapSet.intersection(winning, mine) |> MapSet.to_list() |> length()

      {tail, points} = spread_points(spread, winners)
      {tail, points + acc}
    end)
    |> then(fn {_, points} -> points end)
  end
end
