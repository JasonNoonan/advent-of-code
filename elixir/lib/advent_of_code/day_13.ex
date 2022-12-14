defmodule AdventOfCode.Day13 do
  @doc """
    # iex> AdventOfCode.Day13.parse("[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]")
    # [[[1,1,3,1,1], [1,1,5,1,1]], [[[1],[2,3,4]], [[1], 4]]]
  """
  def parse(args) do
    args
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn packet ->
      String.split(packet, "\n", trim: true)
      |> Enum.map(fn p ->
        p |> Jason.decode!()
      end)
    end)
  end

  @doc """
    iex> AdventOfCode.Day13.compare(
    ...>[[7],[5,[[3,8,9],[1],5],[[7,4],6,[],0],[1,8,[1,5,9]]],[],[[[8,1,8,8,8],5,0,6],5,5,4]],
    ...>[[7,[[4,6,4,2],[0]],[]]])
    :lower
  """
  def compare([], right) when is_list(right) do
    if Enum.empty?(right), do: :same, else: :lower
  end

  def compare(left, []) when is_list(left) do
    if Enum.empty?(left), do: :same, else: :higher
  end

  def compare([left | lemainder], [right | remainder]) do
    result = compare(left, right)

    result = if result == :same, do: compare(lemainder, remainder), else: result

    result
  end

  def compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :lower
      left > right -> :higher
      left == right -> :same
    end
  end

  def compare([], []), do: :same

  def compare(left, right),
    do: if(is_list(left), do: compare(left, [right]), else: compare([left], right))

  @doc """
    iex> AdventOfCode.Day13.part1("[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]\\n\\n[9]\\n[[8,7,6]]\\n\\n[[4,4],4,4]\\n[[4,4],4,4,4]\\n\\n[7,7,7,7]\\n[7,7,7]\\n\\n[]\\n[3]\\n\\n[[[]]]\\n[[]]\\n\\n[1,[2,[3,[4,[5,6,7]]]],8,9]\\n[1,[2,[3,[4,[5,6,0]]]],8,9]")
    13
  """
  def part1(args) do
    packet_list =
      args
      |> parse()

    IO.inspect(length(packet_list))

    results =
      packet_list
      |> Enum.reduce([], fn [left, right], acc ->
        [compare(left, right) | acc]
      end)
      |> Enum.reverse()
      |> Enum.with_index(1)

    # |> dbg(limit: :infinity)

    results
    |> Enum.filter(fn {x, _} -> x == :lower or x == :same end)
    |> Enum.map(fn {_, index} -> index end)
    |> Enum.sum()
    |> dbg(limit: :infinity)
  end

  @doc """
    iex> AdventOfCode.Day13.part2("[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]\\n\\n[9]\\n[[8,7,6]]\\n\\n[[4,4],4,4]\\n[[4,4],4,4,4]\\n\\n[7,7,7,7]\\n[7,7,7]\\n\\n[]\\n[3]\\n\\n[[[]]]\\n[[]]\\n\\n[1,[2,[3,[4,[5,6,7]]]],8,9]\\n[1,[2,[3,[4,[5,6,0]]]],8,9]]]\\n[[2]]\\n[[6]")
    140
  """
  def part2(args) do
  end
end
