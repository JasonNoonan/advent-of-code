defmodule AdventOfCode.Day10 do
  def parse(args) do
    args
    |> String.split("\n", trim: true)
  end

  def handle_command(command) do
    if String.starts_with?(command, "noop"),
      do: {0, 1},
      else:
        String.split(command)
        |> Enum.chunk_every(2)
        |> Enum.map(fn [_, val] -> {String.to_integer(val), 2} end)
        |> List.first()
  end

  def find_value_at_cycle(cycle, cycle_events) do
    filter = Enum.filter(cycle_events, fn {x, _value, _command} -> cycle == x end)

    {_cycle, value, _command} =
      cond do
        length(filter) > 0 ->
          List.first(filter)

        Enum.empty?(filter) ->
          Enum.filter(cycle_events, fn {x, _value, _command} -> x < cycle end)
          |> List.last()
      end

    value
  end

  def build_cycle_events(commands) do
    for command <- commands,
        {value, cost} = handle_command(command),
        reduce: [{1, 1, "start"}] do
      acc ->
        {current_cycle, current_value, _} = List.first(acc)
        new_cycle = cost + current_cycle
        new_value = value + current_value

        # IO.inspect(%{val: new_value, cycle: new_cycle, command: command})

        [{new_cycle, new_value, command} | acc]
    end
    |> Enum.reverse()
    |> dbg(limit: :infinity)
  end

  def get_whole_cycle(args) do
    cycle_events = parse(args) |> build_cycle_events()
    {max, _, _} = List.last(cycle_events)

    for x <- Range.new(1, max), reduce: [] do
      acc ->
        val = find_value_at_cycle(x, cycle_events)
        [%{cycle: x, value: val} | acc]
    end
  end

  def part1(args) do
    commands = parse(args)

    cycle_events = build_cycle_events(commands)

    for x <- Range.new(20, 220, 40), reduce: 0 do
      acc ->
        value = find_value_at_cycle(x, cycle_events)
        value * x + acc
    end
  end

  def part2(args) do
    cycle_events = parse(args) |> build_cycle_events()

    for cycle <- 1..240, reduce: "" do
      acc ->
        value = find_value_at_cycle(cycle, cycle_events) |> dbg
        normalized_index = (rem(cycle, 40) - 1) |> dbg
        sprite = if value in (normalized_index - 1)..(normalized_index + 1), do: "#", else: "."
        sprite = if normalized_index + 1 == 0, do: sprite <> "\n", else: sprite
        acc <> sprite
    end
    |> IO.puts()
  end

  def draw_screen(pixels) do
  end
end
