defmodule AdventOfCode.Day23Test do
  use ExUnit.Case

  import AdventOfCode.Day23

  @input """
  ....#..
  ..###.#
  #...#.#
  .#...##
  #.###..
  ##.#.##
  .#..#..
  """

  test "part1" do
    result = part1(@input)

    assert result
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
