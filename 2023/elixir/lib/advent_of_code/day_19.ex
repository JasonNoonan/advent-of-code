defmodule AdventOfCode.Day19 do
  import AdventOfCode.Helpers

  def split_workflows(wf_map, flow) do
    r_outer = ~r/(?<name>\w+)\{(?<component_flows>\S+)\}/
    r_inner = ~r/(?<property>\w)?(?<symbol>[\<\>])?(?<value>\d+)?[:]?(?<target>\w+)/

    %{"name" => name, "component_flows" => checks} = Regex.named_captures(r_outer, flow)

    checks = String.split(checks, ",")
    fallthrough = List.last(checks)

    checks =
      for check <- Enum.take(checks, length(checks) - 1), reduce: [] do
        acc ->
          %{"property" => property, "symbol" => symbol, "value" => value, "target" => target} =
            Regex.named_captures(r_inner, check)

          [{property, symbol, String.to_integer(value), target} | acc]
      end
      |> Enum.reverse()

    checks = [{nil, nil, nil, fallthrough} | checks] |> Enum.slide(0, -1)

    Map.put(wf_map, name, checks)
  end

  def map_parts(part) do
    part = String.replace(part, ["{", "}"], "")

    part
    |> String.split(",")
    |> Enum.reduce(%{}, fn p, acc ->
      [property, value] = String.split(p, "=")

      Map.put(acc, property, String.to_integer(value))
    end)
  end

  def check_condition(">", value, target), do: value > target
  def check_condition("<", value, target), do: value < target
  def check_condition(nil, _value, _target), do: true

  def check(_wf_map, _part, "R"), do: nil
  def check(_wf_map, part, "A"), do: part

  def check(wf_map, part, target) do
    rules = Map.get(wf_map, target)

    for {property, symbol, value, i_target} <- rules, reduce: :cont do
      :cont ->
        if check_condition(symbol, Map.get(part, property), value) do
          check(wf_map, part, i_target)
        else
          :cont
        end

      nil ->
        nil

      ^part ->
        part
    end
  end

  def part1(args) do
    [workflows, parts] = String.split(args, "\n\n", trim: true)

    workflows =
      workflows
      |> lines()
      |> Enum.reduce(%{}, fn wf, acc ->
        split_workflows(acc, wf)
      end)

    parts =
      parts
      |> lines()
      |> Enum.reduce([], fn p, acc ->
        [map_parts(p) | acc]
      end)

    for p <- parts do
      check(workflows, p, "in")
    end
    |> Enum.reject(fn x -> is_nil(x) end)
    |> Enum.map(fn p -> Map.values(p) |> Enum.sum() end)
    |> Enum.sum()
  end

  def part2(_args) do
  end
end
