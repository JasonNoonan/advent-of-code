defmodule AdventOfCode.Profiler do
  import AdventOfCode.Day09

  def profile() do
    input = AdventOfCode.Input.get!(9, 2023)
    part1(input)
  end
end
