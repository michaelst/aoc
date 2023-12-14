defmodule AdventOfCode.Day14 do
  def part1(args) do
    tilted_grid =
      args
      |> String.split("\n", trim: true)
      |> Enum.map(&String.codepoints/1)
      |> transpose()
      |> Enum.map(&sort_row(&1, [], []))
      |> transpose()
      |> Enum.with_index()

    row_count = length(tilted_grid)

    Enum.reduce(tilted_grid, 0, fn {row, index}, acc ->
      rounded = Enum.count(row, fn char -> char == "O" end)
      rounded * (row_count - index) + acc
    end)
  end

  def part2(args) do
    grid =
      args
      |> String.split("\n", trim: true)
      |> Enum.map(&String.codepoints/1)

    row_count = length(grid)

    {_, loads} =
      Enum.reduce(0..500, {grid, []}, fn _, {acc, loads} ->
        {tilted_grid, load} = cycle(acc, row_count)
        {tilted_grid, [load | loads]}
      end)

    loads
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.filter(fn {_, list} -> length(list) > 1 end)
    |> Enum.find_value(fn {_, list} ->
      [{load, first_index}, {_, second_index} | _] = Enum.reverse(list)
      step = first_index - second_index
      steps_needed = (1_000_000_000 - 1 - first_index) / step
      steps_needed == floor(steps_needed) && load
    end)
  end

  def cycle(grid, row_count) do
    tilted_grid =
      grid
      |> transpose()
      |> Enum.reverse()
      # north
      |> Enum.map(&sort_row(&1, [], []))
      # west
      |> tilt()
      # south
      |> tilt()
      # east
      |> tilt()
      # twice to get north on top
      |> turn_clockwise()
      |> turn_clockwise()

    # |> IO.inspect()

    load =
      tilted_grid
      |> Enum.with_index()
      |> Enum.reduce(0, fn {row, index}, acc ->
        rounded = Enum.count(row, fn char -> char == "O" end)
        rounded * (row_count - index) + acc
      end)

    {tilted_grid, load}
  end

  def transpose([[] | _]), do: []

  def transpose(list) do
    [
      Enum.map(list, &hd/1)
      | transpose(Enum.map(list, &tl/1))
    ]
  end

  def turn_clockwise([[] | _]), do: []

  def turn_clockwise(list) do
    [
      Enum.map(list, &hd/1) |> Enum.reverse()
      | turn_clockwise(Enum.map(list, &tl/1))
    ]
  end

  def tilt(list) do
    list
    |> turn_clockwise()
    |> Enum.map(&sort_row(&1, [], []))
  end

  def sort_row([], group, sorted) do
    Enum.sort_by(group, &(&1 == "O"))
    |> Kernel.++(sorted)
    |> Enum.reverse()
  end

  def sort_row(["#" | rest], group, sorted) do
    sort_row(
      rest,
      [],
      ["#" | Enum.sort_by(group, &(&1 == "O"))] ++ sorted
    )
  end

  def sort_row([head | tail], group, sorted) do
    sort_row(tail, [head | group], sorted)
  end
end
