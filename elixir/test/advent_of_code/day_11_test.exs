defmodule AdventOfCode.Day11Test do
  use ExUnit.Case

  import AdventOfCode.Day11

  @input """
  Monkey 0:
    Starting items: 79, 98
    Operation: new = old * 19
    Test: divisible by 23
      If true: throw to monkey 2
      If false: throw to monkey 3

  Monkey 1:
    Starting items: 54, 65, 75, 74
    Operation: new = old + 6
    Test: divisible by 19
      If true: throw to monkey 2
      If false: throw to monkey 0

  Monkey 2:
    Starting items: 79, 60, 97
    Operation: new = old * old
    Test: divisible by 13
      If true: throw to monkey 1
      If false: throw to monkey 3

  Monkey 3:
    Starting items: 74
    Operation: new = old + 3
    Test: divisible by 17
      If true: throw to monkey 0
      If false: throw to monkey 1
  """

  test "monkey parser" do
    result = parse(@input)

    assert result == [
             %{
               divider: 23,
               false_target: 3,
               modifier: "19",
               operation: "*",
               starting_items: 'Ob',
               true_target: 2,
               count: 0
             },
             %{
               divider: 19,
               false_target: 0,
               modifier: "6",
               operation: "+",
               starting_items: '6AKJ',
               true_target: 2,
               count: 0
             },
             %{
               divider: 13,
               false_target: 3,
               modifier: "old",
               operation: "*",
               starting_items: 'O<a',
               true_target: 1,
               count: 0
             },
             %{
               divider: 17,
               false_target: 1,
               modifier: "3",
               operation: "+",
               starting_items: 'J',
               true_target: 0,
               count: 0
             }
           ]
  end

  test "part1" do
    result = part1(@input)

    assert result == 10_605
  end

  test "part2" do
    input = nil
    result = part2(@input)

    assert result == 2_713_310_158
  end
end
