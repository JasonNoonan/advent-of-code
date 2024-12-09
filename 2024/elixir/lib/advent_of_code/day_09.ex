defmodule AdventOfCode.Day09 do
  defmodule WholeFiles do
    use Agent

    def start_link() do
      Agent.start_link(fn -> %{next_index: 0, files: %{}, free: %{}} end,
        name: __MODULE__
      )
    end

    def assign_new_block(".", 0), do: Agent.update(__MODULE__, fn x -> x end)

    def assign_new_block(".", size) do
      Agent.update(__MODULE__, fn %{next_index: index, free: free} = state ->
        %{state | next_index: index + size, free: Map.put(free, index, size)}
      end)
    end

    def assign_new_block(value, size) do
      Agent.update(__MODULE__, fn %{next_index: index, files: files} = state ->
        %{
          state
          | next_index: index + size,
            files: Map.put(files, index, {value, size})
        }
      end)
    end

    def get_disk_map() do
      Agent.get(__MODULE__, fn %{free: free, files: files} ->
        files
        |> Map.merge(free)
        |> Enum.sort_by(fn {k, _v} -> k end)
        |> Enum.reduce("", fn
          {_k, {v, s}}, acc ->
            for _i <- 1..s, reduce: acc do
              line ->
                line <> "#{v}"
            end

          {_k, v}, acc ->
            for _i <- 1..v, reduce: acc do
              line ->
                line <> "."
            end
        end)
      end)
    end

    def try_move_file(file_index) do
      Agent.update(__MODULE__, fn %{free: free, files: files} = state ->
        {value, size} = Map.get(files, file_index)

        with {:ok, {k, _v}} <- find_free_space(free, file_index, size) do
          files =
            files
            |> Map.delete(file_index)
            |> Map.put(k, {value, size})

          free =
            resize_and_move_free_space(free, k, size, file_index)

          %{state | free: free, files: files}
        else
          {:error, :no_fit} ->
            state
        end
      end)
    end

    def sorted_files() do
      Agent.get(__MODULE__, fn %{files: files} ->
        Enum.sort_by(files, fn {_k, {v, _size}} -> v end, :desc)
      end)
    end

    def calculate_block_value() do
      Agent.get(__MODULE__, fn %{files: files, free: free} ->
        files
        |> Map.merge(free)
        |> Enum.sort_by(fn {k, _v} -> k end)
        |> Enum.reduce(0, fn
          {k, {v, s}}, acc ->
            for i <- k..(k + s - 1), reduce: acc do
              a ->
                a + i * v
            end

          _free, acc ->
            acc
        end)
      end)
    end

    defp find_free_space(free, index, space) do
      free
      |> Enum.sort_by(fn {k, _v} -> k end)
      |> Enum.find(fn
        {k, v} when k < index and v >= space -> true
        _else -> false
      end)
      |> case do
        nil -> {:error, :no_fit}
        {k, v} -> {:ok, {k, v}}
      end
    end

    defp resize_and_move_free_space(free, old_index, size, file_index) do
      current_size = Map.get(free, old_index)

      free =
        free
        |> Map.delete(old_index)
        |> Map.put(file_index, size)

      free =
        if current_size != size do
          Map.put(free, old_index + size, current_size - size)
        else
          free
        end

      free
    end
  end

  defmodule FileSystem do
    use Agent

    def start_link() do
      Agent.start_link(fn -> %{next_index: 0, disk: %{}} end, name: __MODULE__)
    end

    def assign_new_block(".", 0), do: Agent.update(__MODULE__, fn x -> x end)

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

    to_disk_map(args, FileSystem)
    compact_files()

    FileSystem.calculate_block_value()
  end

  def part2(args) do
    WholeFiles.start_link()

    to_disk_map(args, WholeFiles)

    WholeFiles.sorted_files()
    |> Enum.each(fn {k, {_v, _s}} ->
      WholeFiles.try_move_file(k)
    end)

    WholeFiles.calculate_block_value()
  end

  defp to_disk_map(args, fun) do
    [input] =
      args
      |> String.split("\n", trim: true)

    input
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce({0, 0}, fn
      x, {counter, id} when rem(counter, 2) == 0 ->
        # file
        fun.assign_new_block(id, x)
        {counter + 1, id + 1}

      x, {counter, id} ->
        # free space
        fun.assign_new_block(".", x)
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
