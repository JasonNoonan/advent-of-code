defmodule AdventOfCode.Day05 do
  def get_seeds(seeds) do
    seeds
    |> String.replace("seeds: ", "")
    |> String.split(" ")
  end

  def get_map_ranges(map) do
    map
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.reduce([], fn ranges, acc ->
      [destination | [source | [range]]] =
        String.split(ranges, " ") |> Enum.map(&String.to_integer/1)

      source_range =
        source..(source + range - 1)
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {key, val}, map -> Map.put(map, to_string(key), val) end)

      dest_range =
        destination..(destination + range - 1)
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {val, key}, map -> Map.put(map, to_string(key), val) end)

      [[source_range, dest_range] | acc]
    end)
  end

  def get_map_from_list([target | maps]) do
    {get_map(target), maps}
  end

  def convert(source, target_list) do
    for [source_range, dest_range] <- target_list do
      index = Map.get(source_range, source)

      Map.get(dest_range, to_string(index))
    end
    |> Enum.reject(&is_nil/1)
    |> case do
      [target] -> to_string(target)
      [] -> source
    end
  end

  def part1(args) do
    [seeds | maps] = String.split(args, "\n\n", trim: true)

    {soil, maps} = get_map_from_list(maps)
    {fertilizer, maps} = get_map_from_list(maps)
    {water, maps} = get_map_from_list(maps)
    {light, maps} = get_map_from_list(maps)
    {temperature, maps} = get_map_from_list(maps)
    {humidity, maps} = get_map_from_list(maps)
    {location, _maps} = get_map_from_list(maps)

    seeds
    |> get_seeds()
    |> Enum.map(fn seed ->
      seed
      |> convert(soil)
      |> convert(fertilizer)
      |> convert(water)
      |> convert(light)
      |> convert(temperature)
      |> convert(humidity)
      |> convert(location)
      |> then(&String.to_integer/1)
    end)
    |> Enum.min()
  end

  def part2(_args) do
  end
end
