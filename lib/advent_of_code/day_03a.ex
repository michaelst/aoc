defmodule AdventOfCode.Day03A do
  @symbols ["*", "#", "-", "+", "@", "%", "&", "=", "$", "/"]
  @symbols_and_period ["." | @symbols]
  @numbers ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  def part2(args) do
    lines = String.split(args, "\n", trim: true)

    character_list = Enum.map(lines, &String.split(&1, "", trim: true))
    character_map = list_to_map(character_list)

    Enum.reduce(character_map, 0, fn {row, row_map}, total ->
      Enum.reduce(row_map, total, fn
        {col, symbol}, row_total when symbol in @symbols ->
          find_gears(row_map, character_map, row, col) + row_total

        _item, row_total ->
          row_total
      end)
    end)
  end

  def list_to_map(list) do
    list
    |> Enum.with_index()
    |> Enum.reduce(Map.new(), fn {row, y}, rows ->
      row_values =
        row
        |> Enum.with_index()
        |> Enum.reduce(Map.new(), fn {val, x}, row_acc ->
          Map.put(row_acc, x, val)
        end)

      Map.put(rows, y, row_values)
    end)
  end

  defp find_gears(row_map, character_map, row, col) do
    previous_line_map = Map.get(character_map, row - 1) || Map.new()
    next_line_map = Map.get(character_map, row + 1) || Map.new()

    [
      # before symbol
      parse_number_before_col(row_map, col),
      # after symbol
      parse_number_after_col(row_map, col),
      # row before
      number_from_adjacent_line(previous_line_map, col),
      # row after
      number_from_adjacent_line(next_line_map, col)
    ]
    |> List.flatten()
    |> Enum.reject(&(&1 == ""))
    |> add_gears()
  end

  defp add_gears([first, second]) do
    String.to_integer(first) * String.to_integer(second)
  end

  defp add_gears(_gears), do: 0

  defp parse_number_before_col(row_map, col, acc \\ [])

  defp parse_number_before_col(_row_map, _col, [first, second, third]) do
    first <> second <> third
  end

  defp parse_number_before_col(row_map, col, acc) do
    case Map.get(row_map, col - 1) do
      value when value in @numbers ->
        parse_number_before_col(row_map, col - 1, [value | acc])

      _value ->
        Enum.join(acc)
    end
  end

  defp parse_number_after_col(row_map, col, acc \\ [])

  defp parse_number_after_col(_row_map, _col, [first, second, third]) do
    first <> second <> third
  end

  defp parse_number_after_col(row_map, col, acc) do
    case Map.get(row_map, col + 1) do
      value when value in @numbers ->
        parse_number_after_col(row_map, col + 1, acc ++ [value])

      _value ->
        Enum.join(acc)
    end
  end

  defp number_from_adjacent_line(row_map, col) do
    first = Map.get(row_map, col - 1)
    second = Map.get(row_map, col)
    third = Map.get(row_map, col + 1)

    cond do
      # all symbols
      first in @symbols_and_period and second in @symbols_and_period and
          third in @symbols_and_period ->
        []

      # all numbers
      first in @numbers and second in @numbers and third in @numbers ->
        first <> second <> third

      first in @numbers and third in @numbers ->
        before_number = parse_number_before_col(row_map, col)
        after_number = parse_number_after_col(row_map, col)

        [before_number, after_number]

      first in @numbers and second in @numbers ->
        parse_number_before_col(row_map, col + 1)

      second in @numbers and third in @numbers ->
        parse_number_after_col(row_map, col - 1)

      first in @numbers ->
        parse_number_before_col(row_map, col)

      second in @numbers ->
        second

      third in @numbers ->
        parse_number_after_col(row_map, col)
    end
  end
end
