defmodule AdventOfCode.Day08 do
  @doc """
    iex> AdventOfCode.Day08.parse("30373\\n25512\\n65332\\n33549\\n35390")
    [
      [
        %{height: 3, x: 0, y: 0},
        %{height: 0, x: 1, y: 0},
        %{height: 3, x: 2, y: 0},
        %{height: 7, x: 3, y: 0},
        %{height: 3, x: 4, y: 0}
      ],
      [
        %{height: 2, x: 0, y: 1},
        %{height: 5, x: 1, y: 1},
        %{height: 5, x: 2, y: 1},
        %{height: 1, x: 3, y: 1},
        %{height: 2, x: 4, y: 1}
      ],
      [
        %{height: 6, x: 0, y: 2},
        %{height: 5, x: 1, y: 2},
        %{height: 3, x: 2, y: 2},
        %{height: 3, x: 3, y: 2},
        %{height: 2, x: 4, y: 2}
      ],
      [
        %{height: 3, x: 0, y: 3},
        %{height: 3, x: 1, y: 3},
        %{height: 5, x: 2, y: 3},
        %{height: 4, x: 3, y: 3},
        %{height: 9, x: 4, y: 3}
      ],
      [
        %{height: 3, x: 0, y: 4},
        %{height: 5, x: 1, y: 4},
        %{height: 3, x: 2, y: 4},
        %{height: 9, x: 3, y: 4},
        %{height: 0, x: 4, y: 4}
      ]
    ]
  """
  def parse(args) do
    for {row, y_index} <- String.split(args, "\n", trim: true) |> Enum.with_index(),
        tree = String.graphemes(row),
        indexed_tree = Enum.with_index(tree) do
      indexed_tree
      |> Enum.map(fn {height, x_index} ->
        %{height: String.to_integer(height), x: x_index, y: y_index}
      end)
    end
  end

  @doc """
    iex> AdventOfCode.Day08.part1("30373\\n25512\\n65332\\n33549\\n35390")
    21
  """
  def part1(args) do
    forest = parse(args) |> List.flatten()

    for tree <- forest,
        column = Enum.filter(forest, fn %{height: _, x: x, y: _} -> x == tree.x end),
        row = Enum.filter(forest, fn %{height: _, x: _, y: y} -> y == tree.y end),
        reduce: 0 do
      acc ->
        [l, r] = visible_in_row(row, tree)
        [u, d] = visible_in_column(column, tree)
        acc + if l || r || u || d, do: 1, else: 0
    end
  end

  @doc """
    iex> AdventOfCode.Day08.part2("30373\\n25512\\n65332\\n33549\\n35390")
    8
  """
  def part2(args) do
    forest = parse(args) |> List.flatten()

    for tree <- forest, reduce: [] do
      acc ->
        [get_view_distance_score(forest, tree) | acc]
    end
    |> Enum.sort(:desc)
    |> List.first()
  end

  @doc """
    iex> AdventOfCode.Day08.visible_in_row([%{height: 3,x: 0,y: 0},%{height: 0,x: 1,y: 0},%{height: 3,x: 2,y: 0},%{height: 7,x: 3,y: 0},%{height: 3,x: 4,y: 0}],%{height: 3,x: 2,y: 0})
    [false, false]

    iex> AdventOfCode.Day08.visible_in_row([%{height: 3,x: 0,y: 0},%{height: 0,x: 1,y: 0},%{height: 3,x: 2,y: 0},%{height: 7,x: 3,y: 0},%{height: 3,x: 4,y: 0}],%{height: 7,x: 3,y: 0})
    [true, true]

    iex> AdventOfCode.Day08.visible_in_row([%{height: 3,x: 0,y: 0},%{height: 0,x: 1,y: 0},%{height: 3,x: 2,y: 0},%{height: 7,x: 3,y: 0},%{height: 3,x: 4,y: 0}],%{height: 3,x: 0,y: 0})
    [true, false]

    iex> AdventOfCode.Day08.visible_in_row([
    ...> %{height: 3, x: 0, y: 0},
    ...> %{height: 0, x: 1, y: 0},
    ...> %{height: 3, x: 2, y: 0},
    ...> %{height: 7, x: 3, y: 0},
    ...> %{height: 3, x: 4, y: 0}
    ...> ],%{height: 3, x: 0, y: 0})
    [true, false]
  """
  def visible_in_row(row, position) do
    for %{height: height, x: x, y: _} <- row, reduce: [true, true] do
      [true, right] when x < position.x ->
        if height < position.height, do: [true, right], else: [false, right]

      [left, true] when x > position.x ->
        if height < position.height, do: [left, true], else: [left, false]

      [left, right] ->
        [left, right]
    end
  end

  @doc """
    iex> AdventOfCode.Day08.visible_in_column([%{height: 3, x: 0, y: 0}, %{height: 2, x: 0, y: 1}, %{height: 6, x: 0, y: 2}, %{height: 3, x: 0, y: 3}, %{height: 3, x: 0, y: 4}], %{height: 2, x: 0, y: 1})
    [false, false]

    iex> AdventOfCode.Day08.visible_in_column([%{height: 3, x: 0, y: 0}, %{height: 2, x: 0, y: 1}, %{height: 6, x: 0, y: 2}, %{height: 3, x: 0, y: 3}, %{height: 3, x: 0, y: 4}], %{height: 6, x: 0, y: 2})
    [true, true]

    iex> AdventOfCode.Day08.visible_in_column([%{height: 3, x: 0, y: 0}, %{height: 2, x: 0, y: 1}, %{height: 6, x: 0, y: 2}, %{height: 3, x: 0, y: 3}, %{height: 3, x: 0, y: 4}], %{height: 3, x: 0, y: 4})
    [false, true] 

    iex> AdventOfCode.Day08.visible_in_column([
    ...> %{height: 3, x: 0, y: 0},
    ...> %{height: 2, x: 0, y: 1},
    ...> %{height: 6, x: 0, y: 2},
    ...> %{height: 3, x: 0, y: 3},
    ...> %{height: 3, x: 0, y: 4}
    ...> ], %{height: 3, x: 0, y: 0})
    [true, false]
  """
  def visible_in_column(column, position) do
    for %{height: height, x: _, y: y} <- column, reduce: [true, true] do
      [true, down] when y < position.y ->
        if height < position.height, do: [true, down], else: [false, down]

      [up, true] when y > position.y ->
        if height < position.height, do: [up, true], else: [up, false]

      [up, down] ->
        [up, down]
    end
  end

  @doc """
    iex> AdventOfCode.Day08.get_view_distance_right([%{height: 3,x: 0,y: 0},%{height: 0,x: 1,y: 0},%{height: 3,x: 2,y: 0},%{height: 7,x: 3,y: 0},%{height: 3,x: 4,y: 0}],%{height: 3,x: 0,y: 0})
    2
  """
  def get_view_distance_right(row, position) do
    range = Enum.filter(row, fn %{height: _, x: x, y: _} -> x > position.x end)

    Enum.reduce_while(range, 0, fn tree, acc ->
      if tree.x == position.x, do: {:halt, acc}
      if tree.height < position.height, do: {:cont, acc + 1}, else: {:halt, acc + 1}
    end)
  end

  @doc """
    iex> AdventOfCode.Day08.get_view_distance_left([%{height: 3,x: 0,y: 0},%{height: 0,x: 1,y: 0},%{height: 3,x: 2,y: 0},%{height: 7,x: 3,y: 0},%{height: 3,x: 4,y: 0}],%{height: 3,x: 2,y: 0})
    2

    iex> AdventOfCode.Day08.get_view_distance_left([%{height: 3,x: 0,y: 0},%{height: 0,x: 1,y: 0},%{height: 3,x: 2,y: 0},%{height: 7,x: 3,y: 0},%{height: 3,x: 4,y: 0}],%{height: 3,x: 4,y: 0})
    1
  """
  def get_view_distance_left(row, position) do
    range =
      Enum.filter(row, fn %{height: _, x: x, y: _} -> x < position.x end)
      |> Enum.sort_by(& &1.x, :desc)

    Enum.reduce_while(range, 0, fn tree, acc ->
      if tree.x == position.x, do: {:halt, acc}
      if tree.height < position.height, do: {:cont, acc + 1}, else: {:halt, acc + 1}
    end)
  end

  @doc """
    iex> AdventOfCode.Day08.get_view_distance_down([%{height: 3, x: 0, y: 0}, %{height: 2, x: 0, y: 1}, %{height: 6, x: 0, y: 2}, %{height: 3, x: 0, y: 3}, %{height: 3, x: 0, y: 4}], %{height: 3, x: 0, y: 4})
    0

    iex> AdventOfCode.Day08.get_view_distance_down([%{height: 3, x: 0, y: 0}, %{height: 2, x: 0, y: 1}, %{height: 6, x: 0, y: 2}, %{height: 3, x: 0, y: 3}, %{height: 3, x: 0, y: 4}], %{height: 3, x: 0, y: 0})
    2

    iex> AdventOfCode.Day08.get_view_distance_down([%{height: 3, x: 0, y: 0}, %{height: 2, x: 0, y: 1}, %{height: 6, x: 0, y: 2}, %{height: 3, x: 0, y: 3}, %{height: 3, x: 0, y: 4}], %{height: 6, x: 0, y: 2})
    2
  """
  def get_view_distance_down(column, position) do
    range = Enum.filter(column, fn %{height: _, x: _, y: y} -> y > position.y end)

    Enum.reduce_while(range, 0, fn tree, acc ->
      if tree.y == position.y, do: {:halt, acc}
      if tree.height < position.height, do: {:cont, acc + 1}, else: {:halt, acc + 1}
    end)
  end

  @doc """
    iex> AdventOfCode.Day08.get_view_distance_up([%{height: 3, x: 0, y: 0}, %{height: 2, x: 0, y: 1}, %{height: 6, x: 0, y: 2}, %{height: 3, x: 0, y: 3}, %{height: 3, x: 0, y: 4}], %{height: 3, x: 0, y: 4})
    1

    iex> AdventOfCode.Day08.get_view_distance_up([%{height: 3, x: 0, y: 0}, %{height: 2, x: 0, y: 1}, %{height: 6, x: 0, y: 2}, %{height: 3, x: 0, y: 3}, %{height: 3, x: 0, y: 4}], %{height: 3, x: 0, y: 0})
    0

    iex> AdventOfCode.Day08.get_view_distance_up([%{height: 3, x: 0, y: 0}, %{height: 2, x: 0, y: 1}, %{height: 6, x: 0, y: 2}, %{height: 3, x: 0, y: 3}, %{height: 3, x: 0, y: 4}], %{height: 6, x: 0, y: 2})
    2
  """
  def get_view_distance_up(column, position) do
    range =
      Enum.filter(column, fn %{height: _, x: _, y: y} -> y < position.y end)
      |> Enum.sort_by(& &1.y, :desc)

    Enum.reduce_while(range, 0, fn tree, acc ->
      if tree.height < position.height, do: {:cont, acc + 1}, else: {:halt, acc + 1}
    end)
  end

  def get_view_distance_score(forest, tree) do
    column = Enum.filter(forest, fn %{height: _, x: x, y: _} -> x == tree.x end)
    row = Enum.filter(forest, fn %{height: _, x: _, y: y} -> y == tree.y end)

    u = get_view_distance_up(column, tree)
    d = get_view_distance_down(column, tree)
    l = get_view_distance_left(row, tree)
    r = get_view_distance_right(row, tree)

    u * d * l * r
  end
end
