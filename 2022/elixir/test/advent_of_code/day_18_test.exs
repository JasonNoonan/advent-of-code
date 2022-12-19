defmodule AdventOfCode.Day18Test do
  use ExUnit.Case

  import AdventOfCode.Day18

  @input """
  2,2,2
  1,2,2
  3,2,2
  2,1,2
  2,3,2
  2,2,1
  2,2,3
  2,2,4
  2,2,6
  1,2,5
  3,2,5
  2,1,5
  2,3,5
  """

  test "part1" do
    result = part1(@input)

    assert result == 64
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
