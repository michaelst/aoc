defmodule AdventOfCode.Day05 do
  def part1(args) do
    [seeds | conversions] = process_input(args)

    seeds
    |> String.split([" ", "\n"], trim: true)
    |> Enum.map(fn seed -> seed |> String.to_integer() |> process_seed(conversions, :add) end)
    |> Enum.min()
  end

  def part2(args) do
    [seeds | conversions] =
      process_input(args)

    all_conversions = all_conversions(conversions)

    {seed_start, _seed_end} =
      seeds
      |> seed_ranges()
      |> filter_ranges(all_conversions)
      |> Enum.min_by(fn {start, _end} -> start end)

    seed_start
  end

  defp seed_ranges(seeds) do
    String.split(seeds, [" ", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, size] ->
      {start, start + size - 1}
    end)
  end

  defp all_conversions(conversions) do
    Enum.map(conversions, fn conversion ->
      String.split(conversion, "\n", trim: true)
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> build_ranges()
    end)
  end

  defp filter_ranges(seeds, []), do: seeds

  defp filter_ranges(seeds, [current | tail]) do
    Enum.map(seeds, fn {seed_start, seed_end} ->
      {seed_start, seed_end, valid_conversions(seed_start, seed_end, current)}
    end)
    |> Enum.flat_map(fn
      {seed_start, seed_end, [{_, _, difference}]} ->
        [{seed_start + difference, seed_end + difference}]

      {seed_start, seed_end, conversions} ->
        Enum.map(conversions, fn {source_start, source_end, difference} ->
          {max(seed_start, source_start) + difference, min(seed_end, source_end) + difference}
        end)
    end)
    |> filter_ranges(tail)
  end

  defp valid_conversions(seed_start, seed_end, conversions) do
    Enum.filter(conversions, fn {source_start, source_end, _difference} ->
      seed_start in source_start..source_end or seed_end in source_start..source_end
    end)
    |> case do
      [] ->
        [{seed_start, seed_end, 0}]

      valid ->
        {min, _, _} =
          Enum.min_by(valid, fn {source_start, _source_end, _difference} -> source_start end)

        {_, max, _} =
          Enum.max_by(valid, fn {_source_start, source_end, _difference} -> source_end end)

        case {min, max} do
          {min, max} when min <= seed_start and max >= seed_end -> valid
          {min, max} when min <= seed_start -> [{max + 1, seed_end, 0} | valid]
          {min, max} when max >= seed_end -> [{0, min - 1, 0} | valid]
          {min, max} -> [{seed_start, min - 1, 0}, {max + 1, seed_end, 0} | valid]
        end
    end
  end

  defp process_seed(value, [], _operation), do: value

  defp process_seed(seed, [current | tail], operation) do
    String.split(current, "\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> build_ranges()
    |> lookup(seed, operation)
    |> process_seed(tail, operation)
  end

  defp lookup([], seed, _operation), do: seed

  defp lookup([{source_start, source_end, difference} | tail], seed, :add) do
    if seed in source_start..source_end do
      seed + difference
    else
      lookup(tail, seed, :add)
    end
  end

  defp lookup([{source_start, source_end, difference} | tail], seed, :subtract) do
    if seed in source_start..source_end do
      seed - difference
    else
      lookup(tail, seed, :subtract)
    end
  end

  defp build_ranges(numbers, ranges \\ [])
  defp build_ranges([], ranges), do: ranges

  defp build_ranges([[destination, source, size] | tail], ranges) do
    destination = String.to_integer(destination)
    source = String.to_integer(source)
    size = String.to_integer(size)

    difference = destination - source

    build_ranges(tail, [{source, source + size - 1, difference} | ranges])
  end

  defp process_input(input) do
    String.split(
      input,
      [
        "seeds: ",
        "seed-to-soil map:",
        "soil-to-fertilizer map:",
        "fertilizer-to-water map:",
        "water-to-light map:",
        "light-to-temperature map:",
        "temperature-to-humidity map:",
        "humidity-to-location map:"
      ],
      trim: true
    )
  end
end
