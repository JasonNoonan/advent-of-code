defmodule AdventOfCode.Day16 do
  def get_weighted_paths(graph, rooms, start_room, time_remaining) do
    for {name, _} <- rooms, reduce: [] do
      r ->
        if name != start_room, do: [Graph.dijkstra(graph, start_room, name) | r], else: r
    end
    |> calculate_path_cost(rooms, time_remaining)
  end

  def get_closed_valves(rooms) do
    rooms
    |> Enum.filter(&(&1.state == :closed))
    |> Enum.sort_by(& &1.rate, :desc)
  end

  def calculate_path_cost(path_list, rooms, time_remaining) do
    # TODO: Need to add logic for determining if the cost of opening a valve along the path
    # is worth an extra round of not having the end valve open
    for nodes <- path_list do
      for {node, travel_time} <- Enum.with_index(nodes), room = rooms[node], reduce: {0, 0} do
        {flow_increase, time_spent} ->
          acc =
            if room.state != :closed,
              do: {flow_increase, time_spent + travel_time},
              else:
                (
                  after_open = time_remaining - travel_time - 1
                  {flow_increase + room.rate * after_open, time_spent + travel_time + 1}
                )

          acc
      end
    end
  end

  def open_valve(_graph, _rooms, _target) do
    # set the state of the target room to :open

    # for each connection of the current room, update
    # the edge in the graph to set the weight to 0
  end

  def part1(args) do
    input_regex =
      ~r/Valve (?<name>\w+) has flow rate=(?<rate>.+); tunnel[s]? lead[s]? to valve[s]? (?<connections>.*)/

    graph = Graph.new()

    {graph, _rooms} =
      for line <- String.split(args, "\n", trim: true), reduce: {graph, %{}} do
        {graph, acc} ->
          m = Regex.named_captures(input_regex, line)

          name = m["name"]

          room = %{
            rate: String.to_integer(m["rate"]),
            state: :closed
          }

          graph =
            for c <- String.split(m["connections"], ", "), reduce: graph do
              acc ->
                Graph.add_edge(acc, name, c, weight: room.rate * -1)
            end

          room = Map.put(room, :connections, Graph.neighbors(graph, name))
          acc = Map.put(acc, name, room)

          {graph, acc}
      end

    {_response, list} = Graph.to_dot(graph)
    IO.write(list)
    # get_weighted_paths(graph, rooms, "AA", 30) |> dbg
  end

  def part2(_args) do
  end
end
