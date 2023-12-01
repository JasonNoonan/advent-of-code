defmodule AdventOfCode.Day25 do
  @snafu %{
    "2" => 2,
    "1" => 1,
    "0" => 0,
    "-" => -1,
    "=" => -2
  }

  @decimal %{
    "2" => "2",
    "1" => "1",
    "0" => "0",
    "-1" => "-",
    "-2" => "="
  }

  def get_length(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.graphemes(x) end)
    |> Enum.max_by(fn x -> length(x) end)
    |> length()
    |> dbg
  end

  def snafu_to_decimal(args) do
    args
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {val, idx} ->
      place = 5 ** idx
      value = Map.get(@snafu, val)
      value * place
    end)
    |> Enum.sum()
  end

  def to_snafu(decimal) do
    to_string(decimal)
  end

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn s ->
      snafu_to_decimal(s)
    end)
  end

  def part2(_args) do
  end
end
