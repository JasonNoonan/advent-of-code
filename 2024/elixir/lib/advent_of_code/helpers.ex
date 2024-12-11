defmodule AdventOfCode.Helpers do
  @doc """
  Converts a 2D list to a map of coordinates with the given value

  ## Examples

      iex> Helpers.list_to_map([[1,2,3], [4,5,6]])
      %{{0, 0} => 1, {0, 1} => 4, {1, 0} => 2, {1, 1} => 5, {2, 0} => 3, {2, 1} => 6}
  """
  @spec list_to_map([[any()]]) :: map()
  def list_to_map(list) do
    Enum.with_index(list)
    |> Enum.reduce(Map.new(), fn {row, y}, acc ->
      Enum.with_index(row)
      |> Enum.reduce(acc, fn {val, x}, row_acc ->
        Map.put(row_acc, {x, y}, val)
      end)
    end)
  end

  @doc """
  Prints out a visualization of a provided map of {x,y} points.
  Defaults to y=0 on the top, can be switched with the `inverted` option as `true.`
  Also accepts a display function that will pass the value of the key at that point to format the value.
  ## Examples

      iex> Helpers.list_to_map([[true,false,true], [false,true,false]]) |> Helpers.print_map()

      #.#
      .#.
      %{
      {0, 0} => true,
      {0, 1} => false,
      {1, 0} => false,
      {1, 1} => true,
      {2, 0} => true,
      {2, 1} => false
      }

      iex> Helpers.list_to_map([[true,false,true], [false,true,false]]) |> Helpers.print_map([inverted: true, display: fn x -> if x, do: "😂", else: "⬛" end])

      ⬛😂⬛
      😂⬛😂
      %{
        {0, 0} => true,
        {0, 1} => false,
        {1, 0} => false,
        {1, 1} => true,
        {2, 0} => true,
        {2, 1} => false
      } 
  """
  @spec print_map(map()) :: map()
  def print_map(map, opts \\ []) do
    inverted = opts[:inverted] || false
    display = opts[:display] || fn x -> if x, do: "#", else: "." end

    {{{x_min, _}, _}, {{x_max, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
    {{{_, y_min}, _}, {{_, y_max}, _}} = Enum.min_max_by(map, fn {{_, y}, _} -> y end)
    y_range = if inverted, do: y_max..y_min, else: y_min..y_max

    IO.write("\n")

    Enum.each(y_range, fn y ->
      Enum.each(x_min..x_max, fn x ->
        Map.get(map, {x, y})
        |> display.()
        |> IO.write()
      end)

      IO.write("\n")
    end)

    map
  end

  def enqueue(queue, []), do: queue

  def enqueue(queue, [i | tail]) do
    :queue.in(i, queue)
    |> enqueue(tail)
  end

  def enqueue(queue, val), do: enqueue(queue, [val])

  def dequeue(queue), do: :queue.out(queue)

  def lines(string), do: String.split(string, "\n", trim: true)

  def divided_lines(string),
    do: String.split(string, "\n\n", trim: true) |> Enum.map(&String.split(&1, "\n", trim: true))

  @doc """
  Gets the Euclidean distance between two points

  ## Examples

      iex> Helpers.euclidean_distance({-2, 4}, {3, 3})
      5.0990195135927845
  """

  @spec euclidean_distance({number, number}, {number, number}) :: float
  def euclidean_distance({x1, y1}, {x2, y2}) do
    Integer.pow(abs(x2 - x1), 2)
    |> Kernel.+(Integer.pow(abs(y2 - y1), 2))
    |> :math.sqrt()
  end

  @doc """
  Finds the slope of the line between two points.

  Returns either an :ok tuple with a nested tuple containing the `m` and `b`
  values (the slope as a float and the point at which the line intercepts the
  y-axis, the y-intercept as a float.), or an :error tuple indicating that the
  points create a vertical line. 

  Also returns :error, :same_point if you try to pass it the same point twice.
  """
  @spec find_slope({number, number}, {number, number}) ::
          {:ok, {float, float}} | {:error, :undefined} | {:error, :same_point}
  def find_slope({x, y}, {x, y}), do: {:error, :same_point}
  def find_slope({x, _y1}, {x, _y2}), do: {:error, :undefined}

  def find_slope({x1, y1}, {x2, y2}) do
    m = (y2 - y1) / (x2 - x1)
    b = y1 - m * x1

    {:ok, {m, b}}
  end

  @doc """
  Given a point, a slope, and the y-intercept of a line, determines if the
  point is on the given line. 

  Returns boolean value indicating if the point is on that line.
  """
  @spec in_line?({number, number}, float(), float()) :: boolean()
  def in_line?({x, y}, m, b), do: y == m * x + b

  @doc """
  Gets all adjacent points on a map of XY coordinates to a point

  Pass `all: false` to not include diagonally adjacent points
  Pass `default: <value>` to retrieve some other value than nil by default
  Pass `three_d: true` to use a three dimensional map

  ## Examples
      iex> Helpers.get_adj(%{{0, 0} => 1, {0, 1} => 4, {1, 0} => 2, {1, 1} => 5, {2, 0} => 3, {2, 1} => 6}, {1,1})
      %{{0, 0} => 1, {0, 1} => 4, {1, 0} => 2, {1, 1} => 5, {2, 0} => 3, {2, 1} => 6}
  """
  def get_adj(map, {x, y}, opts \\ []) do
    default = Keyword.get(opts, :default, nil)
    all = Keyword.get(opts, :all, true)
    three_d = Keyword.get(opts, :three_d, false)

    deltas =
      cond do
        all ->
          for(x <- [-1, 0, 1], y <- [-1, 0, 1], do: {x, y})

        three_d ->
          for(x <- [-1, 0, 1], y <- [-1, 0, 1], z <- [-1, 0, 1], do: {x, y, z})

        true ->
          [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
      end

    deltas
    |> Enum.reduce(Map.new(), fn {dx, dy}, acc ->
      new_point = {x + dx, y + dy}

      new_point_val = Map.get(map, new_point, default)

      if new_point_val do
        Map.put(acc, new_point, new_point_val)
      else
        acc
      end
    end)
  end

  @doc """
  Gets shortest path to a destination.

  """
  @spec dijkstras(
          map(),
          {number(), number()},
          {number(), number()},
          (number(), any(), any() -> number() | :infinity)
        ) :: number()
  def dijkstras(map, start, dest, get_cost) do
    dijkstras(
      [{start, 0}],
      map,
      dest,
      Map.new(Enum.map(Map.keys(map), &{&1, :infinity})),
      get_cost
    )
  end

  def dijkstras([], _map, _dest, _costs, _get_cost), do: :infinity

  def dijkstras(queue, map, dest, costs, get_cost) do
    [{node, cost} | rest_queue] = queue

    if node == dest do
      cost
    else
      neighbors = get_adj(map, node, all: false) |> Map.keys()

      # add neighbor with added weight to queue
      {new_queue, new_costs} =
        Enum.reduce(neighbors, {rest_queue, costs}, fn neighbor, {q_acc, c_acc} = acc ->
          current_cost = Map.get(costs, neighbor)
          start = Map.get(map, node)
          next = Map.get(map, neighbor)
          new_cost = get_cost.(cost, start, next)

          if new_cost < current_cost do
            {[{neighbor, new_cost} | q_acc], Map.put(c_acc, neighbor, new_cost)}
          else
            acc
          end
        end)

      dijkstras(Enum.sort(new_queue), map, dest, new_costs, get_cost)
    end
  end

  def least_common_multiple(list) do
    list
    |> Enum.reduce(1, fn x, acc ->
      (acc * x)
      |> Integer.floor_div(Integer.gcd(x, acc))
    end)
  end

  def slide(enum, window \\ 2, every \\ 1, option \\ :discard) do
    Enum.chunk_every(enum, window, every, option)
  end

  @doc """
  Calculates the area of a polygon given a list of points that comprise that shape.

  iex> shoelace_algo([{1, 1}, {4, 1}, {4, 4}, {1, 4}])
  9.0

  iex> shoelace_algo([{1, 1}, {5, 1}, {5, 5}, {1, 5}])
  16.0
  """
  def shoelace_algo(points) do
    shifted = Enum.slide(points, 0, -1)

    points =
      Enum.zip_with(points, shifted, fn {x, y}, {xn, yn} ->
        {x * yn, y * xn}
      end)

    for {a, b} <- points, reduce: 0 do
      area ->
        area
        |> Kernel.+(a)
        |> Kernel.-(b)
    end
    |> abs()
    |> Kernel.*(0.5)
  end

  @doc """
  Calculates the internal area of a polygon

  inner: 
  """
  def picks_theorem(area, perimeter_length, option \\ :inner) do
    b = perimeter_length / 2

    if option == :inner do
      area - b + 1
    else
      area + b + 1
    end
  end

  defmodule Graph do
    alias AdventOfCode.Helpers

    @moduledoc """
     A simple graph data structure with edges and vertices
    """
    @type t :: %__MODULE__{vertices: MapSet.t(any), edges: MapSet.t(MapSet.t(any))}
    defstruct vertices: MapSet.new(), edges: MapSet.new(), neighbors: %{}

    @spec new :: %Graph{}
    def new, do: %Graph{}

    @doc """
    Add vertex to graph. Is idempotent.

    """
    @spec add_vertex(%Graph{}, any) :: %Graph{}
    def add_vertex(%Graph{vertices: vertices} = graph, vertex) do
      Map.put(graph, :vertices, MapSet.put(vertices, vertex))
    end

    @doc """
    Add vertices in a lit to graph. Is idempotent for individual vertices.

    """
    @spec add_vertices(%Graph{}, list(any)) :: %Graph{}
    def add_vertices(graph, vertices) do
      Enum.reduce(vertices, graph, fn vertex, acc ->
        Map.put(acc, :vertices, MapSet.put(acc.vertices, vertex))
      end)
    end

    @doc """
    Add edge to graph. Is idempotent.

    """
    @spec add_edge(%Graph{}, any) :: %Graph{}
    def add_edge(%Graph{edges: edges} = graph, edge) do
      Map.put(graph, :edges, MapSet.put(edges, MapSet.new(edge)))
      |> Map.update!(:neighbors, fn neighbors ->
        [edge_a, edge_b] = edge

        Map.update(neighbors, edge_a, MapSet.new(), &MapSet.put(&1, edge_b))
        |> Map.update(edge_b, MapSet.new(), &MapSet.put(&1, edge_a))
      end)
    end

    @doc """
    Get all vertices connected to a given vertex.

    """
    @spec neighbors(%Graph{}, any) :: list
    def neighbors(%Graph{neighbors: neighbors}, vertex) do
      Map.get(neighbors, vertex) |> MapSet.to_list()
    end

    def map_to_graph(map, edge_fun) do
      Enum.reduce(map, Graph.new(), fn {point, val}, graph ->
        graph = Graph.add_vertex(graph, {point, val})

        for {p, v} <- Helpers.get_adj(map, point), reduce: graph do
          g ->
            case edge_fun.({point, val}, {p, v}) do
              {:ok, edge} -> Graph.add_edge(g, edge)
              {:error, _no} -> g
            end
        end
      end)
    end

    def bfs(graph, start) do
      dbg("start: #{inspect(start)}")
      bfs(%{}, graph, neighbors(graph, start), [], 1)
    end

    defp bfs(paths, _, [], [], _), do: paths

    defp bfs(paths, graph, [], neighbors, layer), do: bfs(paths, graph, neighbors, [], layer + 1)

    defp bfs(paths, graph, [node | tail], neighbors, layer) when is_map_key(paths, node) do
      bfs(paths, graph, tail, neighbors, layer)
    end

    defp bfs(paths, graph, [node | tail], neighbors, layer) do
      Map.put(paths, node, layer)
      |> bfs(graph, tail, neighbors(graph, node) ++ neighbors, layer)
    end

    defimpl Inspect, for: Graph do
      import Inspect.Algebra

      def inspect(graph, opts) do
        concat([
          "%Graph{\n     vertices: ",
          to_doc(MapSet.to_list(graph.vertices), opts),
          ",\n     edges: ",
          to_doc(MapSet.to_list(graph.edges) |> Enum.map(&MapSet.to_list/1), opts)
        ])
      end
    end
  end

  defmodule Tree do
    @moduledoc """
    A simple tree data structure and helper functions for traversal algorithms
    """

    @type t :: %__MODULE__{value: any(), children: []}
    defstruct [:value, :children]

    @spec new :: t()
    def new, do: %Tree{children: []}

    @spec new(any(), []) :: t()
    def new(value, children \\ []), do: %Tree{value: value, children: children}

    @spec traverse(t(), fun()) :: []
    @spec traverse(stack :: [], fun :: fun(), history :: []) :: []
    def traverse(tree, fun) do
      traverse([tree], fun, [])
    end

    def traverse([], _fun, history), do: history

    def traverse([%__MODULE__{value: value, children: children} | stack], fun, history) do
      case fun.(value, history) do
        {:stop, response} ->
          [response | history]

        {:continue, response} ->
          if is_list(children) do
            children
            |> Enum.reduce(stack, fn child, acc -> [child | acc] end)
            |> traverse(fun, [response | history])
          else
            traverse(stack, fun, [response | history])
          end
      end
    end
  end
end
