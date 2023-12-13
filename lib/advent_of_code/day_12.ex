defmodule AdventOfCode.Day12 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [springs, broken] = String.split(line, " ", trim: true)
      springs = String.codepoints(springs)
      broken = broken |> String.split(",") |> Enum.map(&String.to_integer/1)
      {springs, broken}
    end)
    |> Task.async_stream(fn {springs, broken} ->
      find_combos({springs, broken})
    end)
    |> Stream.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [springs, broken] = String.split(line, " ", trim: true)
      springs = String.codepoints(springs)
      broken = broken |> String.split(",") |> Enum.map(&String.to_integer/1)

      {
        springs ++ ["?" | springs] ++ ["?" | springs] ++ ["?" | springs] ++ ["?" | springs],
        Enum.flat_map(1..5, fn _ -> broken end)
      }
    end)
    |> Task.async_stream(
      fn {springs, broken} ->
        find_combos({springs, broken})
      end,
      timeout: 240_000
    )
    |> Stream.map(fn {:ok, result} -> result end)
    |> Enum.map(& &1)
    |> Enum.sum()
  end

  def find_combos(info, prev_spring \\ ".")

  # this combo worked, so add 1
  def find_combos({[], []}, _prev_spring), do: 1
  def find_combos({[], [0]}, _prev_spring), do: 1

  # not possible, didn't use all broken
  def find_combos({[], _not_empty}, _prev_spring), do: 0

  def find_combos(
        {[next_spring | springs], broken},
        prev_spring
      ) do
    case {next_spring, prev_spring, broken} do
      # not possible, ran out of broken
      {"#", _, []} ->
        0

      {"#", _, [0 | _]} ->
        0

      # check if there are any springs left that need to be counted as there are no more broken left
      {_, _, []} ->
        if Enum.member?(springs, "#"), do: 0, else: 1

      # this is a valid combo as spring group has ended and we aren't expecting anymore broken
      {".", "#", [0 | broken]} ->
        find_combos({springs, broken}, next_spring)

      # not possible, no more springs to count on current broken
      {".", "#", _} ->
        0

      # nothing to see here
      {".", ".", _} ->
        find_combos({springs, broken}, next_spring)

      # one of the broken is found
      {"#", _, [current_broken | broken]} ->
        find_combos({springs, [current_broken - 1 | broken]}, next_spring)

      # we have no more broken in this group so treat as a "."
      {"?", "#", [0 | broken]} ->
        find_combos({springs, broken}, ".")

      # test as a spring for the current group
      {"?", "#", [current_broken | broken]} ->
        find_combos({springs, [current_broken - 1 | broken]}, "#")

      {"?", ".", [current_broken | broken]} ->
        # test as a spring and not as start of new group
        memoized({springs, [current_broken | broken]}, fn ->
          find_combos({springs, [current_broken - 1 | broken]}, "#") +
            find_combos({springs, [current_broken | broken]}, ".")
        end)
    end
  end

  defp memoized(key, fun) do
    with nil <- Process.get(key) do
      fun.() |> tap(&Process.put(key, &1))
    end
  end
end
