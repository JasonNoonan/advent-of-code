defmodule AdventOfCode.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Day09
  alias AdventOfCode.Point
  doctest AdventOfCode.Day09

  # test "part1" do
  #   input = "R 4\nU 4\nL 3\nD 1\nR 4\nD 1\nL 5\nR 2"
  #
  #   result = part1(input)
  #   result == 13
  # end

  # test "touches?" do
  #   h = %Point{x: 1, y: 1}
  #   t1 = %Point{x: 1, y: 0}
  #   t2 = %Point{x: 3, y: 2}
  #
  #   touching?({h, t1, t2}) == true
  # end
  #
  # test "overlaps?" do
  #   h = %Point{x: 1, y: 1}
  #   t = %Point{x: 2, y: 1}
  #
  #   overlaps?(h, t) == true
  # end
end
