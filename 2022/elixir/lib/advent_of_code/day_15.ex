defmodule AdventOfCode.Day15 do
  @beacon_regex ~r/Sensor at x=(?<sensor_x>.+), y=(?<sensor_y>.+): closest beacon is at x=(?<beacon_x>.+), y=(?<beacon_y>.+)/

  def get_manhattan_distance(x1, y1, x2, y2) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def parse(args) do
    lines =
      args
      |> String.split("\n", trim: true)

    for line <- lines, reduce: {[], []} do
      {sensors, beacons} ->
        match = Regex.named_captures(@beacon_regex, line)

        s = %{
          x: String.to_integer(match["sensor_x"]),
          y: String.to_integer(match["sensor_y"])
        }

        b = %{
          x: String.to_integer(match["beacon_x"]),
          y: String.to_integer(match["beacon_y"])
        }

        s = %{
          x: s.x,
          y: s.y,
          d: get_manhattan_distance(s.x, s.y, b.x, b.y)
        }

        {[s | sensors], [b | beacons]}
    end
  end

  def part1(args, y \\ 2_000_000) do
    {sensors, beacons} = parse(args)

    {s_min_x, s_max_x} = Enum.min_max_by(sensors, fn s -> s.x end)
    {b_min_x, b_max_x} = Enum.min_max_by(beacons, fn b -> b.x end)
    %{x: _, y: _, d: max_range} = Enum.max_by(sensors, fn s -> s.d end)
    {min_x, max_x} = Enum.min_max([s_min_x.x, b_min_x.x, s_max_x.x, b_max_x.x])
    min_x = min_x - max_range
    max_x = max_x + max_range

    for x <- min_x..max_x, reduce: 0 do
      points ->
        visible =
          Enum.reduce(sensors, [], fn s, seen ->
            distance_to_sensor = get_manhattan_distance(x, y, s.x, s.y)
            beacon_here = Enum.find(beacons, fn b -> b.x == x and b.y == y end)
            [distance_to_sensor <= s.d and is_nil(beacon_here) | seen]
          end)
          |> Enum.any?(fn seen -> seen end)

        points = if visible, do: points + 1, else: points
        points
    end
    |> dbg
  end

  def found_in_scan?(max, x, y), do: x >= 0 and x <= max and y >= 0 and y <= max

  def part2(args, max \\ 4_000_000) do
    {sensors, _} = parse(args)

    scanned =
      for s <- sensors, reduce: [] do
        adjacent ->
          scanned =
            for dx <- 0..(s.d + 1), dy = s.d + 1 - dx, reduce: [] do
              acc ->
                acc =
                  if found_in_scan?(max, s.x + dx, s.y + dy),
                    do: [{s.x + dx, s.y + dy} | acc],
                    else: acc

                acc =
                  if found_in_scan?(max, s.x - dx, s.y + dy),
                    do: [{s.x - dx, s.y + dy} | acc],
                    else: acc

                acc =
                  if found_in_scan?(max, s.x + dx, s.y - dy),
                    do: [{s.x + dx, s.y - dy} | acc],
                    else: acc

                acc =
                  if found_in_scan?(max, s.x - dx, s.y - dy),
                    do: [{s.x - dx, s.y - dy} | acc],
                    else: acc

                acc
            end

          [scanned | adjacent]
      end
      |> List.flatten()
      |> Enum.uniq()
      |> dbg

    in_range =
      Enum.reduce(sensors, [], fn s, acc ->
        filter =
          Enum.filter(scanned, fn p ->
            get_manhattan_distance(s.x, s.y, elem(p, 0), elem(p, 1)) <= s.d
          end)

        [filter | acc]
      end)
      |> List.flatten()

    {x, y} = (scanned -- in_range) |> List.first()

    x * 4_000_000 + y
  end
end
