defmodule AdventOfCode.Day06 do
  @doc """
    iex> AdventOfCode.Day06.part1("mjqjpqmgbljsphdztnvjfqwrcgsmlb")
    7

    iex> AdventOfCode.Day06.part1("bvwbjplbgvbhsrlpgdmjqwftvncz")
    5

    iex> AdventOfCode.Day06.part1("nppdvjthqldpwncqszvftbrmjlhg")
    6

    iex> AdventOfCode.Day06.part1("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg")
    10

    iex> AdventOfCode.Day06.part1("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw")
    11
  """
  def part1(args) do
    get_index(String.graphemes(args), 4)
  end

  @doc """
    iex> AdventOfCode.Day06.part2("mjqjpqmgbljsphdztnvjfqwrcgsmlb")
    19

    iex> AdventOfCode.Day06.part2("bvwbjplbgvbhsrlpgdmjqwftvncz")
    23

    iex> AdventOfCode.Day06.part2("nppdvjthqldpwncqszvftbrmjlhg")
    23

    iex> AdventOfCode.Day06.part2("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg")
    29

    iex> AdventOfCode.Day06.part2("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw")
    26

  """
  def part2(args) do
    get_index(String.graphemes(args), 14)
  end

  @doc """
    iex> AdventOfCode.Day06.get_index(String.graphemes("mjqjpqmgbljsphdztnvjfqwrcgsmlb"), 4)
    7

    iex> AdventOfCode.Day06.get_index(String.graphemes("mjqjpqmgbljsphdztnvjfqwrcgsmlb"), 14)
    19
  """
  def get_index(input, size) do
    indexes =
      for {_, index} <- input |> Enum.with_index(),
          slice = Enum.slice(input, index, size),
          uniq = Enum.uniq(slice),
          reduce: [] do
        acc ->
          if Enum.count(uniq) == size,
            do: [index + size | acc],
            else: acc
      end

    List.first(Enum.reverse(indexes))
  end
end
