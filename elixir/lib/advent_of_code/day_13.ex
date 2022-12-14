defmodule Packet do
  defstruct value: []

  def compare(%Packet{value: a}, %Packet{value: b}) do
    do_compare(a, b)
  end

  @doc """
    iex> AdventOfCode.Day13.compare(
    ...>[[8,6,[],2],[7],[8,0,[7,0],[[5,6],10,[10]]],[3,8,[],[[8,9],4]],[]],
    ...>[[3,[2,[9,4,4],1],[[3],[],[7,10,6,6],[8,6]]],[[8,5],[2,[],[7]]]])
    :gt
  """
  def do_compare([], right) when is_list(right) do
    if Enum.empty?(right), do: :eq, else: :lt
  end

  def do_compare(left, []) when is_list(left) do
    if Enum.empty?(left), do: :eq, else: :gt
  end

  def do_compare([left | lemainder], [right | remainder]) do
    result = do_compare(left, right)

    result = if result == :eq, do: do_compare(lemainder, remainder), else: result

    result
  end

  def do_compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :lt
      left > right -> :gt
      left == right -> :eq
    end
  end

  def do_compare([], []), do: :eq

  def do_compare(left, right),
    do: if(is_list(left), do: do_compare(left, [right]), else: do_compare([left], right))
end

defmodule AdventOfCode.Day13 do
  @doc """
    iex> AdventOfCode.Day13.parse("[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]")
    [%Packet{value: [1, 1, 3, 1, 1]}, %Packet{value: [1, 1, 5, 1, 1]}, %Packet{value: [[1], [2, 3, 4]]}, %Packet{value: [[1], 4]}]
  """
  def parse(args) do
    args
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn packet ->
      String.split(packet, "\n", trim: true)
    end)
    |> List.flatten()
    |> Enum.map(fn p ->
      %Packet{value: Jason.decode!(p)}
    end)
  end

  @doc """
    iex> AdventOfCode.Day13.part1("[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]\\n\\n[9]\\n[[8,7,6]]\\n\\n[[4,4],4,4]\\n[[4,4],4,4,4]\\n\\n[7,7,7,7]\\n[7,7,7]\\n\\n[]\\n[3]\\n\\n[[[]]]\\n[[]]\\n\\n[1,[2,[3,[4,[5,6,7]]]],8,9]\\n[1,[2,[3,[4,[5,6,0]]]],8,9]")
    13
  """
  def part1(args) do
    packet_list =
      args
      |> parse()

    results =
      packet_list
      |> Enum.chunk_every(2)
      |> Enum.reduce([], fn [left, right], acc ->
        [Packet.compare(left, right) | acc]
      end)
      |> Enum.reverse()
      |> Enum.with_index(1)

    # |> dbg(limit: :infinity)

    results
    |> Enum.filter(fn {x, _} -> x == :lt or x == :eq end)
    |> Enum.map(fn {_, index} -> index end)
    |> Enum.sum()

    # |> dbg(limit: :infinity)
  end

  @doc """
    iex> AdventOfCode.Day13.part2("[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]\\n\\n[9]\\n[[8,7,6]]\\n\\n[[4,4],4,4]\\n[[4,4],4,4,4]\\n\\n[7,7,7,7]\\n[7,7,7]\\n\\n[]\\n[3]\\n\\n[[[]]]\\n[[]]\\n\\n[1,[2,[3,[4,[5,6,7]]]],8,9]\\n[1,[2,[3,[4,[5,6,0]]]],8,9]")
    140
  """
  def part2(args) do
    packet_list =
      args
      |> parse()

    packet_list = [%Packet{value: [[2]]} | packet_list]
    packet_list = [%Packet{value: [[6]]} | packet_list]

    result =
      packet_list
      |> Enum.sort(Packet)
      |> Enum.with_index(1)
      |> dbg

    {_, first} = Enum.find(result, fn {%Packet{value: x}, _} -> x == [[2]] end)
    {_, second} = Enum.find(result, fn {%Packet{value: x}, _} -> x == [[6]] end)
    first * second
  end
end
