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
    tail_steps = [%{dir: "HOLD", amount: 1}]

    steps =
      for step <- String.split(args, "\n", trim: true),
          [dir, amount] = String.split(step),
          reduce: [] do
        acc ->
          [%{dir: dir, amount: String.to_integer(amount)} | acc]
      end
      |> Enum.reverse()

    {_head, _tail, _head_pos, tail_pos, _tail_steps} =
      for step <- steps, reduce: {head, tail, head_pos, tail_pos, tail_steps} do
        {head, tail, head_pos, tail_pos, tail_steps} ->
          step(step, head, tail, head_pos, tail_pos, tail_steps)
      end

    Enum.uniq(tail_pos) |> length
  end

  @doc """
    iex> AdventOfCode.Day09.part2("R 5\\nU 8\\nL 8\\nD 3\\nR 17\\nD 10\\nL 25\\nU 20")
    31

    # iex> AdventOfCode.Day09.part2("R 5\\nU 8\")
    # 1

    iex> AdventOfCode.Day09.part2("R 4\\nU 4\\nL 3\\nD 1\\nR 4\\nD 1\\nL 5\\nR 2")
    1
  """
  def part2(args) do
    head = %Point{x: 0, y: 0}
    tail = %Point{x: 0, y: 0}
    head_pos = [head]
    tail_pos = [tail]
    tail_steps = [%{dir: "HOLD", amount: 0}]

    steps =
      for step <- String.split(args, "\n", trim: true),
          [dir, amount] = String.split(step),
          reduce: [] do
        acc ->
          [%{dir: dir, amount: String.to_integer(amount)} | acc]
      end
      |> Enum.reverse()

    {_steps, _head, _tail, _head_pos, new_tail_pos, _new_tail_steps} =
      for _ <- 0..9, reduce: {steps, head, tail, head_pos, tail_pos, tail_steps} do
        {o_steps, _head, _tail, _head_pos, _tail_pos, _tail_steps} ->
          {_head, _tail, _head_pos, o_tail_pos, new_tail_steps} =
            for step <- o_steps, reduce: {head, tail, head_pos, tail_pos, tail_steps} do
              {head, tail, head_pos, tail_pos, tail_steps} ->
                step(step, head, tail, head_pos, tail_pos, tail_steps)
            end

          {Enum.reverse(new_tail_steps), head, tail, head_pos, o_tail_pos, tail_steps}
      end

    new_tail_pos |> Enum.uniq() |> length
  end

  @doc """
  for a given step of "R 5" or "U 10", etc, moves the head and tail and returns the new list of places they've been
  """
  def step(step, head, tail, head_pos, tail_pos, tail_steps) do
    {step, head, head_pos} = move_head(step, head, head_pos)
    {tail, tail_pos, tail_steps} = chase_head(head_pos, tail, tail_pos, tail_steps)

    case step.amount do
      x when x > 0 ->
        step(step, head, tail, head_pos, tail_pos, tail_steps)

      x when x == 0 ->
        {head, tail, head_pos, tail_pos, tail_steps}
    end
  end

  @doc """
  Moves the head by one step in the given direction and returns the decremented amount of steps remaining
  """
  def move_head(%{dir: dir, amount: amount} = step, head, head_pos) do
    head =
      case dir do
        "R" -> %Point{x: head.x + 1, y: head.y}
        "L" -> %Point{x: head.x - 1, y: head.y}
        "U" -> %Point{x: head.x, y: head.y - 1}
        "D" -> %Point{x: head.x, y: head.y + 1}
        "UL" -> %Point{x: head.x - 1, y: head.y - 1}
        "UR" -> %Point{x: head.x + 1, y: head.y - 1}
        "DL" -> %Point{x: head.x - 1, y: head.y + 1}
        "DR" -> %Point{x: head.x + 1, y: head.y + 1}
        "HOLD" -> head
      end

    head_pos = [head | head_pos]

    step = Map.put(step, :amount, amount - 1)

    {step, head, head_pos}
  end

  @doc """
  moves the tail in pursuit of the provided head list
  """
  def chase_head(head_pos, tail, tail_pos, tail_steps) do
    head = List.first(head_pos)
    diff = {head.x - tail.x, head.y - tail.y}

    {new_tail, move} =
      case diff do
        # Up - Left
        {-2, y} when y < 0 ->
          {%Point{x: tail.x - 1, y: tail.y - 1}, "UL"}

        {x, -2} when x < 0 ->
          {%Point{x: tail.x - 1, y: tail.y - 1}, "UL"}

        # Up - Right
        {2, y} when y < 0 ->
          {%Point{x: tail.x + 1, y: tail.y - 1}, "UR"}

        {x, -2} when x > 0 ->
          {%Point{x: tail.x + 1, y: tail.y - 1}, "UR"}

        # Down - Left
        {-2, y} when y > 0 ->
          {%Point{x: tail.x - 1, y: tail.y + 1}, "DL"}

        {x, 2} when x < 0 ->
          {%Point{x: tail.x - 1, y: tail.y + 1}, "DL"}

        # Down - Right
        {2, y} when y > 0 ->
          {%Point{x: tail.x + 1, y: tail.y + 1}, "DR"}

        {x, 2} when x > 0 ->
          {%Point{x: tail.x + 1, y: tail.y + 1}, "DR"}

        # Right
        {2, 0} ->
          {%Point{x: tail.x + 1, y: tail.y}, "R"}

        # Left
        {-2, 0} ->
          {%Point{x: tail.x - 1, y: tail.y}, "L"}

        # Up
        {0, -2} ->
          {%Point{x: tail.x, y: tail.y - 1}, "U"}

        # Down
        {0, 2} ->
          {%Point{x: tail.x, y: tail.y + 1}, "D"}

        # same or adjacent
        {_, _} ->
          {tail, "HOLD"}
      end

    step = List.first(tail_steps)

    new_tail_steps =
      cond do
        move != step.dir ->
          new_step = %{dir: move, amount: 1}
          [new_step | tail_steps]

        move == step.dir ->
          {to_update, remainder} = Enum.split(tail_steps, 1)
          s = List.first(to_update)
          new_step = Map.put(s, :amount, s.amount + 1)
          [new_step | remainder]
      end

    tail_pos = [new_tail | tail_pos]
    {new_tail, tail_pos, new_tail_steps}
  end

  # def capture_move(current_pos, new_pos, tail_steps) do
  #   step = List.first(tail_steps)
  #
  #   new_step_dir =
  #     case {new_pos.x - current_pos.x, new_pos.y - current_pos.y} do
  #       {-1, -1} -> "UL"
  #       {1, -1} -> "UR"
  #       {-1, 1} -> "DL"
  #       {1, 1} -> "DR"
  #       {1, 0} -> "R"
  #       {-1, 0} -> "L"
  #       {0, -1} -> "U"
  #       {0, 1} -> "D"
  #       {0, 0} -> "HOLD"
  #     end
  #
  #   cond do
  #     step.dir != new_step_dir ->
  #       new_step = %{dir: new_step_dir, amount: 1}
  #       [new_step | tail_steps]
  #
  #     step.dir == new_step_dir ->
  #       {to_update, remainder} = Enum.split(tail_steps, 1)
  #       s = List.first(to_update)
  #       new_step = Map.put(s, :amount, s.amount + 1)
  #       [new_step | remainder]
  #   end
  # end

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
