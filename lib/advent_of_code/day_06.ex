defmodule AdventOfCode.Day06 do
  def part1(args) do
    ["Time:" <> times, "Distance:" <> distances] = String.split(args, "\n", trim: true)
    times = String.split(times, " ", trim: true) |> Enum.map(&String.to_integer/1)
    distances = String.split(distances, " ", trim: true) |> Enum.map(&String.to_integer/1)

    Enum.zip(times, distances)
    |> Enum.map(&calculate_distance/1)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def part2(args) do
    ["Time:" <> times, "Distance:" <> distances] = String.split(args, "\n", trim: true)
    time = String.replace(times, " ", "") |> String.to_integer()
    distance = String.replace(distances, " ", "") |> String.to_integer()

    calculate_end({time, distance}, 1, time - 1) -
      calculate_beginning({time, distance}, 1, time - 1)
  end

  defp calculate_distance({time, distance}) do
    calculate_end({time, distance}, 1, time - 1) -
      calculate_beginning({time, distance}, 1, time - 1)
  end

  defp calculate_beginning(_race, start_time, end_time) when start_time == end_time do
    start_time
  end

  defp calculate_beginning({race_time, record}, start_time, end_time) do
    ms = floor((end_time - start_time) / 2) + start_time

    result = (race_time - ms) * ms

    if result > record do
      calculate_beginning({race_time, record}, start_time, ms)
    else
      calculate_beginning({race_time, record}, ms + 1, end_time)
    end
  end

  defp calculate_end(_race, start_time, end_time) when start_time == end_time do
    start_time
  end

  defp calculate_end({race_time, record}, start_time, end_time) do
    ms = floor((end_time - start_time) / 2 + start_time)

    result = (race_time - ms) * ms

    if result > record do
      calculate_end({race_time, record}, ms + 1, end_time)
    else
      calculate_end({race_time, record}, start_time, ms)
    end
  end
end
