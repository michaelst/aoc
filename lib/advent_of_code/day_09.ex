defmodule AdventOfCode.Day09 do
  def part1(args) do
    String.split(args, "\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.reverse()
    end)
    |> Enum.map(&process_sequence/1)
    |> Enum.map(&hd/1)
    |> Enum.sum()
  end

  def part2(args) do
    String.split(args, "\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.reverse()
    end)
    |> Enum.map(&process_sequence/1)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&process_sequence/1)
    |> Enum.map(&hd/1)
    |> Enum.sum()
  end

  defp process_sequence(sequence, acc \\ []) do
    next_sequence =
      differences(sequence)
      |> Enum.reverse()

    if Enum.all?(next_sequence, &(&1 == 0)) do
      predict([next_sequence, sequence | acc])
    else
      process_sequence(next_sequence, [sequence | acc])
    end
  end

  defp predict([final]), do: final

  defp predict([first, second | tail]) do
    next = [hd(first) + hd(second) | second]

    predict([next | tail])
  end

  defp differences(sequence, acc \\ [])

  defp differences([_], acc), do: acc

  defp differences([first | [second | _] = tail], acc) do
    differences(tail, [first - second | acc])
  end
end
