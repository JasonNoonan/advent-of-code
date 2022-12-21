defmodule AdventOfCode.Day20Test do
  use ExUnit.Case

  import AdventOfCode.Day20

  @input """
  1
  2
  -3
  3
  -2
  0
  4
  """

  @input2 """
  8
  -6
  3
  0
  12
  """

  test "part1" do
    result = part1(@input)

    assert result == 3
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
