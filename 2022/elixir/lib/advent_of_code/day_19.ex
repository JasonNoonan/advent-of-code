defmodule OreCollector do
  defstruct ore: 0
end

defmodule ClayCollector do
  defstruct ore: 0
end

defmodule ObsidianCollector do
  defstruct ore: 0, clay: 0
end

defmodule GeodeCollector do
  defstruct ore: 0, obsidian: 0
end

defmodule Blueprint do
  defstruct multiplier: 0,
            ore: %OreCollector{},
            clay: %ClayCollector{},
            obsidian: %ObsidianCollector{},
            geode: %GeodeCollector{}
end

defmodule AdventOfCode.Day19 do
  def parse(args) do
    reg =
      ~r/Blueprint (?<multiplier>\d+): Each ore robot costs (?<ore_ore_cost>\d+) ore. Each clay robot costs (?<clay_ore_cost>\d+) ore. Each obsidian robot costs (?<obsidian_ore_cost>\d+) ore and (?<obsidian_clay_cost>\d+) clay. Each geode robot costs (?<geode_ore_cost>\d+) ore and (?<geode_obsidian_cost>\d+) obsidian./

    for blueprint <- String.split(args, "\n", trim: true),
        m = Regex.named_captures(reg, blueprint),
        reduce: [] do
      list ->
        [
          %Blueprint{
            multiplier: m["multiplier"] |> String.to_integer(),
            ore: %OreCollector{ore: m["ore_ore_cost"] |> String.to_integer()},
            clay: %ClayCollector{ore: m["clay_ore_cost"] |> String.to_integer()},
            obsidian: %ObsidianCollector{
              ore: m["obsidian_ore_cost"] |> String.to_integer(),
              clay: m["obsidian_clay_cost"] |> String.to_integer()
            },
            geode: %GeodeCollector{
              ore: m["geode_ore_cost"] |> String.to_integer(),
              obsidian: m["geode_obsidian_cost"] |> String.to_integer()
            }
          }
          | list
        ]
    end
  end

  def part1(args) do
    blueprints = parse(args)
  end

  def part2(_args) do
  end
end
