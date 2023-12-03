defmodule AdventOfCode.Day03A do
  @symbols ["*", "#", "-", "+", "@", "%", "&", "=", "$", "/"]
  @numbers ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  def part2(args) do
    lines = String.split(args, "\n", trim: true)
    total_rows = length(lines)

    [first_row | _rows] = character_list = Enum.map(lines, &String.split(&1, "", trim: true))
    total_cols = length(first_row)

    character_tuple = list_to_tuple(character_list)

    Enum.reduce(0..(total_rows - 1), 0, fn row, total ->
      row_tuple = elem(character_tuple, row)

      Enum.reduce(0..(total_cols - 1), total, fn
        col, row_total ->
          case elem(row_tuple, col) do
            symbol when symbol in @symbols ->
              find_gears(row_tuple, character_tuple, row, col) + row_total

            _other ->
              row_total
          end
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

  def list_to_tuple(list) do
    list
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple()
  end

  def get_coordinate(tuple, index) do
    elem(tuple, index)
  rescue
    _error -> nil
  end

  defp find_gears(row_tuple, character_tuple, row, col) do
    previous_line_tuple = get_coordinate(character_tuple, row - 1) || {}
    next_line_tuple = get_coordinate(character_tuple, row + 1) || {}

    [
      # before symbol
      parse_number_before_col(row_tuple, col),
      # after symbol
      parse_number_after_col(row_tuple, col),
      # row before
      number_from_adjacent_line(previous_line_tuple, col),
      # row after
      number_from_adjacent_line(next_line_tuple, col)
    ]
    |> List.flatten()
    |> Enum.reject(&(&1 == ""))
    |> add_gears()
  end

  defp add_gears([first, second]) do
    String.to_integer(first) * String.to_integer(second)
  end

  defp add_gears(_gears), do: 0

  defp parse_number_before_col(row_tuple, col, acc \\ [])

  defp parse_number_before_col(_row_tuple, _col, [first, second, third]) do
    first <> second <> third
  end

  defp parse_number_before_col(row_tuple, col, acc) do
    case get_coordinate(row_tuple, col - 1) do
      value when value in @numbers ->
        parse_number_before_col(row_tuple, col - 1, [value | acc])

      _value ->
        Enum.join(acc)
    end
  end

  defp parse_number_after_col(row_tuple, col, acc \\ [])

  defp parse_number_after_col(_row_tuple, _col, [first, second, third]) do
    first <> second <> third
  end

  defp parse_number_after_col(row_tuple, col, acc) do
    case get_coordinate(row_tuple, col + 1) do
      value when value in @numbers ->
        parse_number_after_col(row_tuple, col + 1, acc ++ [value])

      _value ->
        Enum.join(acc)
    end
  end

  defp number_from_adjacent_line(row_tuple, col) do
    first = get_coordinate(row_tuple, col - 1)
    second = get_coordinate(row_tuple, col)
    third = get_coordinate(row_tuple, col + 1)

    case {first in @numbers, second in @numbers, third in @numbers} do
      {true, true, true} ->
        first <> second <> third

      {true, true, false} ->
        parse_number_before_col(row_tuple, col + 1)

      {false, true, true} ->
        parse_number_after_col(row_tuple, col - 1)

      {false, true, false} ->
        second

      {true, false, true} ->
        before_number = parse_number_before_col(row_tuple, col)
        after_number = parse_number_after_col(row_tuple, col)

        [before_number, after_number]

      {true, false, false} ->
        parse_number_before_col(row_tuple, col)

      {false, false, true} ->
        parse_number_after_col(row_tuple, col)

      {false, false, false} ->
        []
    end
  end
end
