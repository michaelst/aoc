defmodule AdventOfCode.Day13 do
  def part1(args) do
    args
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn pattern ->
      pattern
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> find_reflection()
    end)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn pattern ->
      pattern_lines =
        pattern
        |> String.split("\n", trim: true)
        |> Enum.with_index()

      without_correction = find_reflection(pattern_lines)
      find_reflection(pattern_lines, 1, without_correction)
    end)
    |> Enum.sum()
  end

  def find_reflection(string, corrections \\ 0, without_correction \\ nil) do
    do_find_reflection(string, string, corrections, without_correction)
  end

  def do_find_reflection(
        string,
        original,
        multiplier \\ 100,
        corrections,
        without_correction,
        transposed \\ false
      )

  def do_find_reflection([_], _original, _multiplier, _corrections, _without_correction, true) do
    nil
  end

  def do_find_reflection([_], original, _multiplier, corrections, without_correction, false) do
    transposed =
      original
      |> Enum.map(fn {line, _} -> String.codepoints(line) end)
      |> transpose()
      |> Enum.map(&Enum.join/1)
      |> Enum.with_index()

    do_find_reflection(transposed, transposed, 1, corrections, without_correction, true)
  end

  def do_find_reflection(
        [{_line, left}, {next_line, right} | rest],
        original,
        multiplier,
        corrections,
        without_correction,
        transposed
      ) do
    cond do
      without_correction == right * multiplier ->
        do_find_reflection(
          [{next_line, right} | rest],
          original,
          multiplier,
          corrections,
          without_correction,
          transposed
        )

      is_mirror?(original, left, right, corrections) ->
        right * multiplier

      true ->
        do_find_reflection(
          [{next_line, right} | rest],
          original,
          multiplier,
          corrections,
          without_correction,
          transposed
        )
    end
  end

  def is_mirror?(lines, left, right, corrections) when is_integer(left) and is_integer(right) do
    is_mirror?(
      lines,
      Enum.slice(lines, 0..left) |> Enum.reverse(),
      Enum.slice(lines, right..-1),
      corrections
    )
  end

  def is_mirror?(_lines, left, right, _corrections) when left == [] or right == [] do
    true
  end

  def is_mirror?(lines, [{next_left, _} | rest_left], [{next_right, _} | rest_right], corrections) do
    if corrections > 0 do
      case compare_strings(next_left, next_right) do
        [] ->
          is_mirror?(lines, rest_left, rest_right, corrections)

        [_one] ->
          is_mirror?(lines, rest_left, rest_right, corrections - 1)

        _ ->
          false
      end
    else
      next_left == next_right and
        is_mirror?(lines, rest_left, rest_right, corrections)
    end
  end

  def transpose([[] | _]), do: []

  def transpose(list) do
    [
      Enum.map(list, &hd/1)
      | transpose(Enum.map(list, &tl/1))
    ]
  end

  def compare_strings(left, right) do
    Enum.zip(
      String.codepoints(left),
      String.codepoints(right)
    )
    |> Enum.filter(fn {left, right} -> left != right end)
  end
end
