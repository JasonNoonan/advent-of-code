defmodule AdventOfCode.Day05 do
  def part1(args) do
    {stacks, instructions} = parse(args)

    endstate =
      for command <- instructions, reduce: stacks do
        acc ->
          execute_command(command, acc, true)
      end

    for key <- Map.keys(endstate) do
      List.first(endstate[key])
    end
    |> List.to_string()
  end

  def part2(args) do
    {stacks, instructions} = parse(args)

    endstate =
      for command <- instructions, reduce: stacks do
        acc ->
          execute_command(command, acc, false)
      end

    for key <- Map.keys(endstate) do
      List.first(endstate[key])
    end
    |> List.to_string()
  end

  @doc """
    iex> AdventOfCode.Day05.parse("    [D]    \\n[N] [C]    \\n[Z] [M] [P]\\n 1   2   3 \\n\\nmove 1 from 2 to 1\\nmove 3 from 1 to 3\\nmove 2 from 2 to 1\\nmove 1 from 1 to 2\\n")
    {
      %{1 => ["N", "Z"], 2 => ["D", "C", "M"], 3 => ["P"]}, 
      [
        %{"count" => "1", "from" => "2", "to" => "1"},
        %{"count" => "3", "from" => "1", "to" => "3"},
        %{"count" => "2", "from" => "2", "to" => "1"},
        %{"count" => "1", "from" => "1", "to" => "2"}
      ]
    }  
  """
  def parse(args) do
    [crates, instructions] = String.split(args, "\n\n")

    {parse_stacks(crates), parse_instructions(instructions)}
  end

  @doc """
    iex> AdventOfCode.Day05.parse_stacks("    [D]    \\n[N] [C]    \\n[Z] [M] [P]\\n 1   2   3")
    %{1 => ["N", "Z"], 2 => ["D", "C", "M"], 3 => ["P"]}
  """
  def parse_stacks(args) do
    args
    |> String.split("\n")
    |> List.delete_at(-1)
    |> Enum.map(fn row ->
      String.to_charlist(row)
      |> Stream.chunk_every(4)
      |> Enum.map(fn crate -> String.replace(to_string(crate), ~r/[^a-zA-Z0-9]/, "") end)
    end)
    |> Enum.reduce(%{}, fn row, acc ->
      row_map =
        row
        |> Enum.with_index()
        |> Enum.filter(fn {x, _} -> String.length(x) > 0 end)
        |> Enum.group_by(fn {_, index} -> index + 1 end, fn {crate, _} -> crate end)

      Map.merge(acc, row_map, fn _k, v1, v2 -> List.flatten(v1, v2) end)
    end)
  end

  @doc """
    iex> AdventOfCode.Day05.parse_instructions("move 1 from 2 to 1\\nmove 3 from 1 to 3\\nmove 2 from 2 to 1\\nmove 1 from 1 to 2\\n")
    [
      %{"count" => "1", "from" => "2", "to" => "1"},
      %{"count" => "3", "from" => "1", "to" => "3"},
      %{"count" => "2", "from" => "2", "to" => "1"},
      %{"count" => "1", "from" => "1", "to" => "2"}
    ]
  """
  def parse_instructions(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn command ->
      Regex.named_captures(~r/^move (?<count>\d+) from (?<from>\d+) to (?<to>\d+)$/, command)
    end)
  end

  @doc """
    iex> AdventOfCode.Day05.execute_command(%{"count" => "1", "from" => "2", "to" => "1"}, %{1 => ["N", "Z"], 2 => ["D", "C", "M"], 3 => ["P"]}, true)
    %{1 => ["D", "N", "Z"], 2 => ["C", "M"], 3 => ["P"]}

    iex> AdventOfCode.Day05.execute_command(%{"count" => "3", "from" => "1", "to" => "3"}, %{1 => ["D", "N", "Z"], 2 => ["C", "M"], 3 => ["P"]}, true)
    %{1 => [], 2 => ["C", "M"], 3 => ["Z", "N", "D", "P"]}

    iex> AdventOfCode.Day05.execute_command(%{"count" => "1", "from" => "2", "to" => "1"}, %{1 => ["N", "Z"], 2 => ["D", "C", "M"], 3 => ["P"]}, false)
    %{1 => ["D", "N", "Z"], 2 => ["C", "M"], 3 => ["P"]}

    iex> AdventOfCode.Day05.execute_command(%{"count" => "3", "from" => "1", "to" => "3"}, %{1 => ["D", "N", "Z"], 2 => ["C", "M"], 3 => ["P"]}, false)
    %{1 => [], 2 => ["C", "M"], 3 => ["D", "N", "Z", "P"]}
  """
  def execute_command(command, target, reverse) do
    from_index = String.to_integer(command["from"])
    to_index = String.to_integer(command["to"])
    count = String.to_integer(command["count"])

    crates_to_move =
      if reverse,
        do: Enum.take(target[from_index], count) |> Enum.reverse(),
        else: Enum.take(target[from_index], count)

    take =
      Map.update(target, from_index, target[from_index], fn current ->
        current -- crates_to_move
      end)

    Map.update(take, to_index, take[to_index], fn current ->
      List.flatten([crates_to_move | current])
    end)
  end
end
