defmodule AdventOfCode.Day07 do
  @doc """
    iex> AdventOfCode.Day07.part1("$ cd /\\n$ ls\\ndir a\\n14848514 b.txt\\n8504156 c.dat\\ndir d\\n$ cd a\\n$ ls\\ndir e\\n29116 f\\n2557 g\\n62596 h.lst\\n$ cd e\\n$ ls\\n584 i\\n$ cd ..\\n$ cd ..\\n$ cd d\\n$ ls\\n4060174 j\\n8033020 d.log\\n5626152 d.ext\\n7214296 k\\n")
    95437
  """
  def part1(args) do
    dirs = ["/"]
    files = []
    path = []

    filesystem =
      for command <- get_commands(args), reduce: %{path: path, dirs: dirs, files: files} do
        acc ->
          parse_command(command, acc.path, acc.dirs, acc.files)
      end

    size_map =
      for dir <- filesystem.dirs, reduce: %{} do
        acc ->
          dir_size =
            Enum.filter(filesystem.files, fn file -> String.starts_with?(file.name, dir) end)
            |> Enum.map(fn file -> file.size end)
            |> Enum.sum()

          Map.put(acc, dir, dir_size)
      end

    for {_, size} <- size_map, reduce: 0 do
      acc ->
        acc + if size <= 100_000, do: size, else: 0
    end
  end

  def part2(_args) do
  end

  @doc """
    iex> AdventOfCode.Day07.get_commands("$ cd /\\n$ ls\\ndir a\\n14848514 b.txt\\n8504156 c.dat\\ndir d\\n$ cd a\\n$ ls\\ndir e\\n29116 f\\n2557 g\\n62596 h.lst\\n$ cd e\\n$ ls\\n584 i\\n$ cd ..\\n$ cd ..\\n$ cd d\\n$ ls\\n4060174 j\\n8033020 d.log\\n5626152 d.ext\\n7214296 k\\n")
    [
      "cd /\\n",
      "ls\\ndir a\\n14848514 b.txt\\n8504156 c.dat\\ndir d\\n",
      "cd a\\n",
      "ls\\ndir e\\n29116 f\\n2557 g\\n62596 h.lst\\n",
      "cd e\\n",
      "ls\\n584 i\\n",
      "cd ..\\n",
      "cd ..\\n",
      "cd d\\n",
      "ls\\n4060174 j\\n8033020 d.log\\n5626152 d.ext\\n7214296 k\\n"
    ]
  """
  def get_commands(input) do
    input |> String.split("$ ", trim: true)
  end

  @doc """
    iex> AdventOfCode.Day07.parse_command("cd /", [], ["/"], [])
    %{path: ["/"], dirs: ["/"], files: []}

    iex> AdventOfCode.Day07.parse_command("ls\\ndir a\\n14848514 b.txt", ["/"], ["/"], [])
    %{path: ["/"], dirs: ["/a", "/"], files: [%{name: "/b.txt", size: 14848514}]}
  """
  def parse_command(command, path, dirs, files) do
    if String.starts_with?(command, "cd"),
      do: change_directory(command, path, dirs, files),
      else:
        list_contents(command)
        |> Enum.reduce(%{dirs: dirs, files: files, path: path}, fn line_item, acc ->
          new_map = parse_line_item(line_item, path, acc.dirs, acc.files)

          Map.put(acc, :dirs, new_map.dirs)
          |> Map.put(:files, new_map.files)
        end)
  end

  @doc """
    iex> AdventOfCode.Day07.change_directory("cd a", ["/"], ["a", "/"], [])
    %{path: ["a", "/"], dirs: ["a", "/"], files: []} 

    iex> AdventOfCode.Day07.change_directory("cd /", [], ["/"], [])
    %{path: ["/"], dirs: ["/"], files: []}

    iex> AdventOfCode.Day07.change_directory("cd ..", ["e", "a", "/"], ["e", "a", "/"], [%{name: "a", size: 1234}])
    %{path: ["a", "/"], dirs: ["e", "a", "/"], files: [%{name: "a", size: 1234}]}

    iex> AdventOfCode.Day07.change_directory("cd ..", ["/"], ["/"], [])
    %{path: ["/"], dirs: ["/"], files: []}
  """
  def change_directory(command, path, dirs, files) do
    [_, dir] = String.split(command)

    path =
      if dir == "..",
        do: go_up_dir(path),
        else: [dir | path]

    %{path: path, dirs: dirs, files: files}
  end

  def go_up_dir(path) do
    if length(path) > 1, do: Enum.drop(path, 1), else: path
  end

  @doc """
    iex> AdventOfCode.Day07.list_contents("ls\\ndir a\\n14848514 b.txt\\n8504156 c.dat\\ndir d\\n")
    ["dir a", "14848514 b.txt", "8504156 c.dat", "dir d"]
  """
  def list_contents(command) do
    [_ | contents] = String.split(command, "\n", trim: true)
    contents
  end

  @doc """
    iex> AdventOfCode.Day07.parse_line_item("14848514 b.txt", ["/"], ["/"], [])
    %{dirs: ["/"], files: [%{name: "/b.txt", size: 14848514}]}

    iex> AdventOfCode.Day07.parse_line_item("dir a", ["/"], ["/"], [])
    %{dirs: ["/a", "/"], files: []}
  """
  def parse_line_item(line, path, dirs, files) do
    if String.starts_with?(line, "dir"),
      do: handle_dir(line, path, dirs, files),
      else: handle_file(line, path, dirs, files)
  end

  @doc """
    iex> AdventOfCode.Day07.handle_dir("dir a", ["/"], ["/"], [])
    %{dirs: ["/a", "/"], files: []}

    iex> AdventOfCode.Day07.handle_dir("dir e", ["a", "/"], ["/d", "/a", "/"], [%{name: "test.txt", size: 1234}])
    %{dirs: ["/a/e", "/d", "/a", "/"], files: [%{name: "test.txt", size: 1234}]}
  """
  def handle_dir(line, path, dirs, files) do
    [_, name] = String.split(line)
    dirname = get_fullname(name, path)
    %{dirs: [dirname | dirs], files: files}
  end

  @doc """
    iex> AdventOfCode.Day07.handle_file("14848514 b.txt", ["/"], ["/"], [])
    %{dirs: ["/"], files: [%{name: "/b.txt", size: 14848514}]}

    iex> AdventOfCode.Day07.handle_file("584 i", ["a", "/"], ["/d", "/a", "/"], [%{name: "test.txt", size: 1234}])
    %{dirs: ["/d", "/a", "/"], files: [%{name: "/a/i", size: 584}, %{name: "test.txt", size: 1234}]}
  """
  def handle_file(line, path, dirs, files) do
    [size, name] = String.split(line)
    filename = get_fullname(name, path)
    %{dirs: dirs, files: [%{name: filename, size: String.to_integer(size)} | files]}
  end

  @doc """
    iex> AdventOfCode.Day07.get_fullname("test", ["child", "parent"])
    "parent/child/test"

    iex> AdventOfCode.Day07.get_fullname("c.dat", ["b", "a", "/"])
    "/a/b/c.dat"
  """
  def get_fullname(name, path) do
    Enum.reverse([name | path]) |> Enum.join("/") |> String.replace("//", "/")
  end
end
