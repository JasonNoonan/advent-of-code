defmodule AdventOfCode.Day07Test do
  use ExUnit.Case

  import AdventOfCode.Day07

  test "part1" do
    input = "32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483"
    result = part1(input)

    assert result == 6440
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
