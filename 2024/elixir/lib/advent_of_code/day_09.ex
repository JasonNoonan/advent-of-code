defmodule AdventOfCode.Day09 do
  defmodule FileSystem do
    use Agent

    def start_link() do
      Agent.start_link(fn -> %{next_index: 0, disk: %{}} end, name: __MODULE__)
    end

    def assign_new_block(".", 0), do: Agent.update(__MODULE__, fn x -> x end)

    # I don't know if this is correct, making an assumption and testing
    def assign_new_block(_, 0) do
      dbg("found file of length zero")

      Agent.update(__MODULE__, fn state ->
        Map.update!(state, :next_index, fn i -> i + 1 end)
      end)
    end

    def assign_new_block(value, size) do
      Agent.update(__MODULE__, fn %{next_index: index, disk: disk} ->
        disk =
          for i <- 0..(size - 1), reduce: disk do
            acc ->
              Map.put(acc, index + i, value)
          end

        %{next_index: index + size, disk: Map.put(disk, index, value)}
      end)
    end

    def get_disk_map() do
      Agent.get(__MODULE__, fn %{next_index: _index, disk: disk} ->
        disk_map_to_string(disk)
      end)
    end

    def find_first_free_space() do
      Agent.get(__MODULE__, fn %{next_index: _index, disk: disk} ->
        disk
        |> to_sorted_list()
        |> Enum.find_value(fn
          {k, "."} -> k
          _ -> false
        end)
      end)
    end

    def find_last_file_index() do
      Agent.get(__MODULE__, fn %{next_index: _index, disk: disk} ->
        disk
        |> to_sorted_list()
        |> Enum.reverse()
        |> Enum.find_value(fn
          {_k, "."} -> false
          {k, _v} -> k
        end)
      end)
    end

    def calculate_block_value() do
      Agent.get(__MODULE__, fn %{disk: disk} ->
        disk
        |> to_sorted_list()
        |> Enum.reduce(0, fn
          {_k, "."}, acc ->
            acc

          {k, v}, acc ->
            acc + k * v
        end)
      end)
    end

    def swap_blocks(a, b) do
      Agent.update(__MODULE__, fn %{next_index: index, disk: disk} ->
        a_data = Map.get(disk, a)
        b_data = Map.get(disk, b)

        disk =
          disk
          |> Map.put(a, b_data)
          |> Map.put(b, a_data)

        %{next_index: index, disk: disk}
      end)
    end

    defp disk_map_to_string(disk) do
      disk
      |> to_sorted_list()
      |> Enum.reduce("", fn {_k, v}, acc ->
        acc <> "#{v}"
      end)
    end

    defp to_sorted_list(disk, order \\ :asc) do
      Enum.sort_by(disk, fn {k, _v} -> k end, order)
    end
  end

  def part1(args) do
    FileSystem.start_link()

    to_disk_map(args)
    compact_files()

    FileSystem.get_disk_map() |> dbg
    FileSystem.calculate_block_value()
  end

  def part2(_args) do
  end

  defp to_disk_map(args) do
    [input] =
      args
      |> String.split("\n", trim: true)

    input
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce({0, 0}, fn
      x, {counter, id} when rem(counter, 2) == 0 ->
        # file
        FileSystem.assign_new_block(id, x)
        {counter + 1, id + 1}

      x, {counter, id} ->
        # free space
        FileSystem.assign_new_block(".", x)
        {counter + 1, id}
    end)
  end

  defp compact_files() do
    first_free_index = FileSystem.find_first_free_space()
    last_file_index = FileSystem.find_last_file_index()

    if first_free_index < last_file_index do
      FileSystem.swap_blocks(first_free_index, last_file_index)
      compact_files()
    end
  end
end
