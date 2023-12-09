defmodule AdventOfCode.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Day09

  test "part1" do
    input = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"
    result = part1(input)

    assert result == 114
  end

  test "part2" do
    input = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"
    result = part2(input)

    assert result == 2
  end
end
