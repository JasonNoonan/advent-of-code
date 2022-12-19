defmodule Point do
  defstruct x: 0, y: 0
end

defmodule AdventOfCode.Day17 do
  def get_points(:flat, x, y) do
    # flat is 4 points including bottom left
    # ####
    [%Point{x: x, y: y}, %Point{x: x + 1, y: y}, %Point{x: x + 2, y: y}, %Point{x: x + 3, y: y}]
  end

  def get_points(:cross, x, y) do
    # cross is 5 points, with bottom left not being in the shape
    #  #
    # ###
    #  #

    [
      %Point{x: x + 1, y: y},
      %Point{x: x, y: y + 1},
      %Point{x: x + 1, y: y + 1},
      %Point{x: x + 2, y: y + 1},
      %Point{x: x + 1, y: y + 2}
    ]
  end

  def get_points(:L, x, y) do
    # L is 5 points, a reverse capital L, including bottom left
    #   #
    #   #
    # ###
    [
      %Point{x: x, y: y},
      %Point{x: x + 1, y: y},
      %Point{x: x + 2, y: y},
      %Point{x: x + 2, y: y + 1},
      %Point{x: x + 2, y: y + 2}
    ]
  end

  def get_points(:l, x, y) do
    # l is 4 points, going straight up, including bottom left
    # #
    # #
    # #
    # #
    [%Point{x: x, y: y}, %Point{x: x, y: y + 1}, %Point{x: x, y: y + 2}, %Point{x: x, y: y + 3}]
  end

  def get_points(:square, x, y) do
    # square is 4 points 2x2 including bottom left
    # ##
    # ##
    [
      %Point{x: x, y: y},
      %Point{x: x + 1, y: y},
      %Point{x: x, y: y + 1},
      %Point{x: x + 1, y: y + 1}
    ]
  end

  def spawn(:flat, x, y) do
    get_points(:flat, x, y)
  end

  def spawn(:cross, x, y) do
    get_points(:cross, x, y)
  end

  def spawn(:L, x, y) do
    get_points(:L, x, y)
  end

  def spawn(:l, x, y) do
    get_points(:l, x, y)
  end

  def spawn(:sqaure, x, y) do
    get_points(:square, x, y)
  end

  def part1(_args) do
  end

  def part2(_args) do
  end
end
