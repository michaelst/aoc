defmodule AdventOfCode.Day03A do
  import AdventOfCode.Helpers

  @symbols ["*", "#", "-", "+", "@", "%", "&", "=", "$", "/"]
  @symbols_and_period ["." | @symbols]
  @numbers ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  def part2(args) do
    lines = String.split(args, "\n", trim: true)

    character_list = Enum.map(lines, &String.split(&1, "", trim: true))
    character_map = list_to_map(character_list)

    lines
    |> Enum.with_index()
    |> Enum.reduce(0, fn {line, row}, acc ->
      characters = String.split(line, "", trim: true) |> Enum.with_index()

      find_gears(characters, character_map, row, 0) + acc
    end)
  end

  defp find_gears([], _character_map, _row, total), do: total

  defp find_gears(
         [{symbol, col} | rest],
         character_map,
         row,
         total
       )
       when symbol in @symbols do
    total =
      [
        # before symbol
        parse_number_before_col(character_map, row, col),
        # after symbol
        parse_number_after_col(character_map, row, col),
        # row before
        number_from_adjacent_line(character_map, row - 1, col),
        # row after
        number_from_adjacent_line(character_map, row + 1, col)
      ]
      |> List.flatten()
      |> add_gears(total)

    # no touching symbols so we can skip next one
    [_next_char | rest] = rest

    find_gears(rest, character_map, row, total)
  end

  defp find_gears(
         [_not_symbol | rest],
         character_map,
         row,
         total
       ) do
    find_gears(rest, character_map, row, total)
  end

  defp add_gears([first, second], total) do
    String.to_integer(first) * String.to_integer(second) + total
  end

  defp add_gears(_gears, total), do: total

  defp parse_number_before_col(character_map, row, col) do
    [first, second, third] = [
      character_map[{col - 3, row}],
      character_map[{col - 2, row}],
      character_map[{col - 1, row}]
    ]

    cond do
      first in @numbers and second in @numbers and third in @numbers ->
        first <> second <> third

      second in @numbers and third in @numbers ->
        second <> third

      third in @numbers ->
        third

      true ->
        []
    end
  end

  defp parse_number_after_col(character_map, row, col) do
    [first, second, third] = [
      character_map[{col + 1, row}],
      character_map[{col + 2, row}],
      character_map[{col + 3, row}]
    ]

    cond do
      first in @numbers and second in @numbers and third in @numbers ->
        first <> second <> third

      first in @numbers and second in @numbers ->
        first <> second

      first in @numbers ->
        first

      true ->
        []
    end
  end

  defp number_from_adjacent_line(character_map, row, col) do
    [first, second, third] = [
      character_map[{col - 1, row}],
      character_map[{col, row}],
      character_map[{col + 1, row}]
    ]

    cond do
      # all symbols
      first in @symbols_and_period and second in @symbols_and_period and
          third in @symbols_and_period ->
        []

      # all numbers
      first in @numbers and second in @numbers and third in @numbers ->
        first <> second <> third

      first in @numbers and third in @numbers ->
        before_number = parse_number_before_col(character_map, row, col)
        after_number = parse_number_after_col(character_map, row, col)

        [before_number, after_number]

      first in @numbers and second in @numbers ->
        parse_number_before_col(character_map, row, col + 1)

      second in @numbers and third in @numbers ->
        parse_number_after_col(character_map, row, col - 1)

      first in @numbers ->
        parse_number_before_col(character_map, row, col)

      second in @numbers ->
        second

      third in @numbers ->
        parse_number_after_col(character_map, row, col)
    end
  end
end
