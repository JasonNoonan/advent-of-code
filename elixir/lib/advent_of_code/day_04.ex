defmodule AdventOfCode.Day04 do
  def part1(args) do
    args
    |> split_to_component_sectors()
    |> Stream.filter(fn [[a, b], [y, z]] ->
      either_fully_contains(Range.new(a, b), Range.new(y, z))
    end)
    |> Enum.count()
  end

  def part2(args) do
    args
    |> split_to_component_sectors()
    |> Stream.filter(fn [[a, b], [y, z]] ->
      !Range.disjoint?(Range.new(a, b), Range.new(y, z))
    end)
    |> Enum.count()
  end

  @doc """
  splits provided range strings into 2 pairs of start,end lists

  ## Examples
    iex> AdventOfCode.Day04.split_to_component_sectors("1-4,2-5\\n3-5,6-9\\n1-9,0-4\\n")
    [[[1, 4], [2, 5]], [[3, 5], [6, 9]], [[1, 9], [0, 4]]]  
  """
  def split_to_component_sectors(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      String.split(x, ",")
      |> Enum.map(fn child ->
        String.split(child, "-")
        |> Enum.map(&String.to_integer/1)
      end)
    end)
  end

  @doc """
  returns true if either a fully contains b, or b fully contains a

  ## Examples
    iex> AdventOfCode.Day04.either_fully_contains(Range.new(1,3), Range.new(4,6))
    false

    iex> AdventOfCode.Day04.either_fully_contains(Range.new(1,3), Range.new(2,2))
    true

    iex> AdventOfCode.Day04.either_fully_contains(Range.new(1,3), Range.new(2,4))
    false
  """
  def either_fully_contains(a, b) do
    !Range.disjoint?(a, b) &&
      (Enum.all?(a, fn i -> i in b end) || Enum.all?(b, fn i -> i in a end))
  end
end
