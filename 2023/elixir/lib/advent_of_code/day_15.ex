defmodule AdventOfCode.Day15 do
  import AdventOfCode.Helpers

  def hashmap(label) do
    label
    |> String.to_charlist()
    |> Enum.reduce(0, fn c, acc ->
      acc
      |> Kernel.+(c)
      |> Kernel.*(17)
      |> rem(256)
    end)
  end

  def part1(args) do
    args
    |> lines()
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> List.flatten()
    |> Enum.map(&hashmap/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> lines()
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> List.flatten()
    |> Enum.reduce(%{}, fn segment, boxes ->
      %{"label" => label, "op" => op, "focal_length" => focal_length} =
        Regex.named_captures(~r/(?<label>\w+)(?<op>[-=])(?<focal_length>\d*)/, segment)

      box = hashmap(label)

      if op == "-" do
        remove_from_box(boxes, box, label)
      else
        update_in_box(boxes, box, label, focal_length)
      end
    end)
    |> Enum.map(fn {box, list} ->
      box = box + 1

      list
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {{_label, focal_length}, index} ->
        [box, index, String.to_integer(focal_length)] |> Enum.product()
      end)
    end)
    |> List.flatten()
    |> Enum.sum()
  end

  def remove_from_box(boxes, box, target) do
    Map.update(boxes, box, [], fn curr -> List.keydelete(curr, target, 0) end)
  end

  def update_in_box(boxes, box, target, focal_length) do
    Map.update(boxes, box, [{target, focal_length}], fn curr ->
      if List.keymember?(curr, target, 0) do
        List.keyreplace(curr, target, 0, {target, focal_length})
      else
        [{target, focal_length} | curr]
      end
    end)
  end
end
