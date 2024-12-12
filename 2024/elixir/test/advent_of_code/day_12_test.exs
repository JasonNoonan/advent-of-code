defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Day12

  test "part1 - simple" do
    input = "AAAA
BBCD
BBCC
EEEC"
    result = part1(input)

    assert result == 140
  end

  @tag :skip
  test "part 1 - inner perimeter" do
    input = "OOOOO
OXOXO
OOOOO
OXOXO
OOOOO"
    result = part1(input)

    assert result == 756
  end

  @tag :skip
  test "part 1 - complex example" do
    input = "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"
    result = part1(input)

    assert result == 1930
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
