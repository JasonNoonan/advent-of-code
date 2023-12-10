defmodule AdventOfCode.Day10Test do
  use ExUnit.Case

  import AdventOfCode.Day10

  test "part1 simple" do
    input = "-L|F7
7S-7|
L|7||
-L-J|
L|-JF"
    result = part1(input)

    assert result == 4
  end

  test "part1 complex" do
    input = "7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ"
    result = part1(input)

    assert result == 8
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
