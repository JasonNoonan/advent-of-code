defmodule AdventOfCode.Day11 do
  @monkey_parse_regex ~r/Monkey \d+:\n\W*Starting items: (?<starting_items>.*)\n\W*Operation: new = old (?<operation>.) (?<modifier>\w+)\n\W*Test: divisible by (?<divider>\w*)\n\W*If true: throw to monkey (?<true_target>\w*)\n\W*If false: throw to monkey (?<false_target>\w*)/

  def parse(args) do
    monkeys = String.split(args, "\n\n", trim: true)

    monkey_list =
      for monkey <- monkeys do
        base = Regex.named_captures(@monkey_parse_regex, monkey)

        %{
          starting_items: get_starting_items_list(base["starting_items"]),
          operation: base["operation"],
          modifier: base["modifier"],
          divider: String.to_integer(base["divider"]),
          true_target: String.to_integer(base["true_target"]),
          false_target: String.to_integer(base["false_target"]),
          count: 0
        }
      end

    monkey_list
  end

  def get_starting_items_list(items) do
    String.split(items, ", ")
    |> Enum.map(&String.to_integer/1)
  end

  def inspect(worry_level, operation, modifier, lower_worry, common_multiple) do
    modifier = if modifier == "old", do: worry_level, else: String.to_integer(modifier)

    during_inspection =
      if operation == "*", do: worry_level * modifier, else: worry_level + modifier

    worry_level =
      if lower_worry,
        do: floor(during_inspection / 3),
        else: rem(during_inspection, common_multiple)

    worry_level
  end

  def test_item(worry_level, divider) do
    rem(worry_level, divider) == 0
  end

  def throw_to_target(worry_level, target) do
    list = target.starting_items |> Enum.reverse()
    [worry_level | list] |> Enum.reverse()
  end

  def calculate_round(monkeys, rounds, lower_worry, common_multiple \\ 0) when rounds > 0 do
    monkeys =
      for i <- 0..(length(monkeys) - 1), reduce: monkeys do
        outer_acc ->
          monkey = Enum.at(outer_acc, i)
          count = length(monkey.starting_items)

          outer_acc =
            for item <- monkey.starting_items,
                after_inspection =
                  inspect(item, monkey.operation, monkey.modifier, lower_worry, common_multiple),
                reduce: outer_acc do
              acc ->
                target_index =
                  if test_item(after_inspection, monkey.divider),
                    do: monkey.true_target,
                    else: monkey.false_target

                target = Enum.at(acc, target_index)
                target_items = throw_to_target(after_inspection, target)
                updated_target = Map.put(target, :starting_items, target_items)
                acc = List.replace_at(acc, target_index, updated_target)
                acc
            end

          updated =
            Map.put(monkey, :starting_items, [])
            |> Map.update(:count, count, fn curr -> curr + count end)

          outer_acc = List.replace_at(outer_acc, i, updated)
          outer_acc
      end

    calculate_round(monkeys, rounds - 1, lower_worry, common_multiple)
  end

  def calculate_round(monkeys, _, _, _), do: monkeys

  def get_product_of_dividers(monkeys) do
    monkeys
    |> Enum.map(fn m -> m.divider end)
    |> Enum.product()
  end

  def part1(args) do
    args
    |> parse()
    |> calculate_round(20, true)
    |> Enum.map(fn x -> x.count end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [x, y] -> x * y end)
    |> List.first()
  end

  def part2(args) do
    monkeys =
      args
      |> parse()

    common_multiple = get_product_of_dividers(monkeys)

    monkeys
    |> calculate_round(10_000, false, common_multiple)
    |> Enum.map(fn x -> x.count end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [x, y] -> x * y end)
    |> List.first()
  end
end
