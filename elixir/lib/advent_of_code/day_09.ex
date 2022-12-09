defmodule AdventOfCode.Point do
  defstruct x: 0, y: 0
end

defmodule AdventOfCode.Day09 do
  alias AdventOfCode.Point

  @doc """
    iex> AdventOfCode.Day09.part1("R 4\\nU 4\\nL 3\\nD 1\\nR 4\\nD 1\\nL 5\\nR 2")
    13
  """
  def part1(args) do
    head = %Point{x: 0, y: 0}
    tail = %Point{x: 0, y: 0}
    head_pos = [head]
    tail_pos = [tail]

    steps =
      for step <- String.split(args, "\n", trim: true),
          [dir, amount] = String.split(step),
          reduce: [] do
        acc ->
          [%{dir: dir, amount: String.to_integer(amount)} | acc]
      end
      |> Enum.reverse()

    {_head, _tail, head_pos, tail_pos} =
      for step <- steps, reduce: {head, tail, head_pos, tail_pos} do
        {head, tail, head_pos, tail_pos} ->
          step(step, head, tail, head_pos, tail_pos)
      end

    uniq = Enum.uniq(tail_pos)
    length(uniq) |> dbg()
  end

  def part2(_args) do
  end

  def draw_frame(h, t, frame) do
    IO.puts("#{frame}")

    for row <- -5..5, reduce: [] do
      acc ->
        list =
          for col <- -5..5, reduce: [] do
            inner_acc ->
              char =
                if col == t.y && row == t.x,
                  do: "t",
                  else: if(col == h.y && row == h.x, do: "h", else: ".")

              [char | inner_acc]
          end
          |> Enum.join("")

        [list | acc]
    end
    |> Enum.join("\n")
    |> IO.puts()
  end

  def step(step, head, tail, head_pos, tail_pos) when step.amount > 0 do
    # draw_frame(head, tail, "starting")

    head =
      case step.dir do
        "R" -> %Point{x: head.x + 1, y: head.y}
        "L" -> %Point{x: head.x - 1, y: head.y}
        "U" -> %Point{x: head.x, y: head.y - 1}
        "D" -> %Point{x: head.x, y: head.y + 1}
      end

    head_pos = [head | head_pos]
    # draw_frame(head, tail, "head_move")
    tail = if overlaps?(head, tail), do: tail, else: Enum.at(head_pos, 1)
    tail_pos = [tail | tail_pos]
    step = Map.put(step, :amount, step.amount - 1)
    # draw_frame(head, tail, "ending")
    step(step, head, tail, head_pos, tail_pos)
  end

  def step(_, head, tail, head_pos, tail_pos), do: {head, tail, head_pos, tail_pos}

  @doc """
    iex> AdventOfCode.Day09.overlaps?(%AdventOfCode.Point{x: 1, y: 1}, %AdventOfCode.Point{x: 2, y: 1})
    true

    iex> AdventOfCode.Day09.overlaps?(%AdventOfCode.Point{x: 2, y: 2}, %AdventOfCode.Point{x: 1, y: 1})
    true
  """
  def overlaps?(head, %Point{x: tx, y: ty}) do
    t1 = %Point{x: tx - 1, y: ty - 1}
    t2 = %Point{x: tx + 1, y: ty + 1}

    points = {head, t1, t2}

    touching?(points)
  end

  @doc """
    iex> AdventOfCode.Day09.touching?({%AdventOfCode.Point{x: 1, y: 1}, %AdventOfCode.Point{x: 1, y: 0}, %AdventOfCode.Point{x: 3, y: 2}})
    true

    iex> AdventOfCode.Day09.touching?({%AdventOfCode.Point{x: 2, y: 2}, %AdventOfCode.Point{x: 0, y: 0}, %AdventOfCode.Point{x: 2, y: 2}})
    true

    iex> AdventOfCode.Day09.touching?({%AdventOfCode.Point{x: 3, y: 3}, %AdventOfCode.Point{x: 0, y: 0}, %AdventOfCode.Point{x: 2, y: 2}})
    false
  """
  def touching?({h, t1, t2}), do: t1.x <= h.x and t1.y <= h.y and t2.x >= h.x and t2.y >= h.y
end
