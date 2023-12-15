defmodule AdventOfCode.Day15 do
  def part1(args) do
    String.split(args, ",")
    |> Enum.map(fn group ->
      group
      |> to_charlist()
      |> hash()
    end)
    |> Enum.sum()
  end

  def part2(args) do
    boxes =
      String.split(args, ",")
      |> Enum.reduce(%{}, fn group, boxes ->
        [label, focal] = String.split(group, ["=", "-"], parts: 2)

        box = label |> to_charlist() |> hash()
        updated_box = process_lens(label, focal, boxes[box] || [])
        Map.put(boxes, box, updated_box)
      end)

    Enum.reduce(0..255, 0, fn box, acc ->
      lens = boxes[box] || []
      multiple_lens(lens, box) + acc
    end)
  end

  def multiple_lens(lens, box) do
    lens
    |> Enum.with_index()
    |> Enum.reduce(0, fn {{_label, focal}, index}, acc ->
      (box + 1) * (index + 1) * focal + acc
    end)
  end

  def process_lens(label, "", box) do
    Enum.filter(box, fn {lens_label, _} -> lens_label != label end)
  end

  def process_lens(label, focal, box) do
    focal = String.to_integer(focal)

    Enum.map(box, fn {lens_label, _} = lens ->
      if lens_label == label do
        {lens_label, focal}
      else
        lens
      end
    end)
    |> Kernel.++([{label, focal}])
    |> Enum.uniq_by(fn {lens_label, _} -> lens_label end)
  end

  def hash(group) do
    Enum.reduce(group, 0, fn x, acc ->
      rem((acc + x) * 17, 256)
    end)
  end
end
