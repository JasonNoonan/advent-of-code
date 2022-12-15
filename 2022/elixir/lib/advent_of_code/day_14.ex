defmodule Point do
  defstruct x: 0, y: 0, contains: @air

  def compare(%Point{x: x, y: y, contains: _}, %Point{x: ox, y: oy, contains: _}) do
    do_compare(x, y, ox, oy)
  end

  def do_compare(lx, ly, rx, ry) when lx == rx and ly != ry do
    cond do
      ly < ry -> :gt
      ly > ry -> :lt
    end
  end

  def do_compare(lx, ly, rx, ry) when lx != rx and ly == ry do
    cond do
      lx < rx -> :lt
      lx > rx -> :gt
    end
  end

  def do_compare(lx, ly, rx, ry) when lx == rx and ly == ry, do: :eq

  def do_compare(_, ly, _, ry) do
    cond do
      ly < ry -> :gt
      ly > ry -> :lt
    end
  end
end

defmodule Grid do
  @air "⬛️"
  @stone "🪨"
  @sand "🟡"

  def create_grid(start_x, start_y, end_x, end_y) do
    grid =
      for y <- start_y..end_y, reduce: [] do
        grid ->
          row =
            for x <- start_x..end_x, reduce: [] do
              row ->
                [%Point{x: x, y: y, contains: @air} | row]
            end

          [row | grid]
      end

    List.flatten(grid) |> Enum.sort(Point)
  end

  def draw_line(grid, lx, ly, rx, ry) when lx == rx do
    for y <- Range.new(ly, ry), reduce: grid do
      acc -> replace_with_stone(acc, lx, y)
    end
  end

  def draw_line(grid, lx, ly, rx, ry) when ly == ry do
    for x <- Range.new(lx, rx), reduce: grid do
      acc -> replace_with_stone(acc, x, ly)
    end
  end

  def replace_with_stone(grid, x, y) do
    index = Enum.find_index(grid, fn %Point{x: px, y: py, contains: _} -> px == x and py == y end)

    List.replace_at(grid, index, %Point{x: x, y: y, contains: @stone})
  end

  def get_objects_below(grid, sand) do
    left =
      Enum.find(grid, fn target ->
        target.x == sand.x - 1 and target.y == sand.y - 1
      end)

    center =
      Enum.find(grid, fn target ->
        target.x == sand.x and target.y == sand.y - 1
      end)

    right =
      Enum.find(grid, fn target ->
        target.x == sand.x + 1 and target.y == sand.y - 1
      end)

    [left, center, right]
  end

  def move_down(grid, sand) do
    target =
      Enum.find(grid, fn target ->
        target.x == sand.x and target.y < sand.y and target.contains not in [@air]
      end)

    landing = Enum.find(grid, fn l -> l.x == target.x and l.y == target.y + 1 end)

    index = Enum.find_index(grid, fn l -> landing.x == l.x and landing.y == l.y end)

    replacement = if target, do: %Point{x: landing.x, y: landing.y, contains: @sand}, else: nil

    if replacement,
      do: [List.replace_at(grid, index, replacement), replacement],
      else: [nil, nil]
  end

  def move_left(grid, sand),
    do: move_down(grid, %Point{x: sand.x - 1, y: sand.y, contains: sand.contains})

  def move_right(grid, sand),
    do: move_down(grid, %Point{x: sand.x + 1, y: sand.y, contains: sand.contains})

  def drop_sand(grid, sand) do
    [left, center, right] = get_objects_below(grid, sand)

    cond do
      center.contains == @air ->
        move_down(grid, sand)

      left.contains == @air ->
        move_left(grid, sand)

      right.contains == @air ->
        move_right(grid, sand)

      true ->
        [grid, sand]
    end
  end

  def visualize(grid) do
    IO.write("\n")

    {x1, x2} = Enum.min_max_by(grid, & &1.x)
    range = Range.new(x1.x, x2.x) |> Enum.to_list()
    width = length(range)

    grid_string = Enum.map(grid, fn x -> x.contains end)
    rows = Enum.chunk_every(grid_string, width)
    rows = Enum.intersperse(rows, ["\n"]) |> List.flatten()

    IO.write(rows)
    IO.write("\n")
  end
end

defmodule AdventOfCode.Day14 do
  @doc """
    iex> AdventOfCode.Day14.part1("498,4 -> 498,6 -> 496,6\\n503,4 -> 502,4 -> 502,9 -> 494,9")
    5
  """
  def part1(args) do
    # 70, 30, 450, 0
    # grid = Grid.create_grid(11, 30, 497, 0)
    grid = Grid.create_grid(493, 0, 504, -9)

    grid =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce(grid, fn line, grid ->
        String.split(line, " -> ")
        |> Enum.chunk_every(2, 1)
        |> Enum.reduce(grid, fn chunk, grid ->
          from = Enum.at(chunk, 0)
          to = Enum.at(chunk, 1)

          grid =
            if is_nil(to),
              do: grid,
              else:
                (
                  [fx, fy] = String.split(from, ",") |> Enum.map(&String.to_integer/1)
                  [tx, ty] = String.split(to, ",") |> Enum.map(&String.to_integer/1)

                  Grid.draw_line(grid, fx, fy * -1, tx, ty * -1)
                )

          grid
        end)
      end)

    [grid, sand] = Grid.drop_sand(grid, %Point{x: 500, y: 0, contains: "🟡"})
    new_sand = Enum.find(grid, fn target -> target.x == sand.x and target.y == sand.y + 1 end)
    [grid, sand] = Grid.drop_sand(grid, new_sand)
    sand |> dbg
    Grid.visualize(grid)
    grid
  end

  def part2(_args) do
  end
end
