defmodule AdventOfCode.Day13 do
  @doc """
    iex> AdventOfCode.Day13.parse("[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]")
    [[1,1,3,1,1], [1,1,5,1,1], [[1],[2,3,4]], [[1], 4]]
  """
  def parse(args) do
    args
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn packet ->
      String.split(packet, "\n", trim: true)
    end)
    |> List.flatten()
    |> Enum.map(fn p ->
      p |> Jason.decode!()
    end)
    |> dbg
  end

  @doc """
    iex> AdventOfCode.Day13.compare(
    ...>[[8,6,[],2],[7],[8,0,[7,0],[[5,6],10,[10]]],[3,8,[],[[8,9],4]],[]],
    ...>[[3,[2,[9,4,4],1],[[3],[],[7,10,6,6],[8,6]]],[[8,5],[2,[],[7]]]])
    :higher
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
      |> dbg

    results =
      packet_list
      |> Enum.chunk_every(2)
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

    # |> dbg(limit: :infinity)
  end

  @doc """
    # iex> AdventOfCode.Day13.part2("[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]\\n\\n[9]\\n[[8,7,6]]\\n\\n[[4,4],4,4]\\n[[4,4],4,4,4]\\n\\n[7,7,7,7]\\n[7,7,7]\\n\\n[]\\n[3]\\n\\n[[[]]]\\n[[]]\\n\\n[1,[2,[3,[4,[5,6,7]]]],8,9]\\n[1,[2,[3,[4,[5,6,0]]]],8,9]")
    # 140
  """
  def part2(args) do
    packet_list =
      args
      |> parse()

    packet_list = [[[2]] | packet_list]
    packet_list = [[[6]] | packet_list] |> dbg

    result =
      packet_list
      |> Enum.sort_by(fn l, r ->
        {l, r} |> dbg

        case compare(l, r) do
          :same -> :eq
          :lower -> :lt
          :higher -> :gt
        end
      end)
      |> Enum.with_index()

    {_, first} = Enum.find(result, fn x -> x == [[2]] end)
    {_, second} = Enum.find(result, fn x -> x == [[6]] end)
    first * second
  end
end
