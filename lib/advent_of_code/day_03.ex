defmodule AdventOfCode.Day03 do
  @symbols ["*", "#", "-", "+", "@", "%", "&", "=", "$", "/"]
  @symbols_and_period ["." | @symbols]
  @numbers ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  def part1(args) do
    lines = String.split(args, "\n", trim: true)

    character_list = Enum.map(lines, &String.split(&1, "", trim: true))

    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, index} ->
      characters = String.split(line, "", trim: true)
      previous_line = Enum.at(character_list, max(index - 1, 0)) || []
      next_line = Enum.at(character_list, index + 1) || []

      numbers = parse_numbers(line)

      {sum, _remaining} =
        Enum.reduce(numbers, {0, characters}, fn number, {sum, remaining} ->
          number
          |> String.split("", trim: true)
          |> include_number?(remaining, previous_line, next_line)
          |> case do
            {true, remaining} -> {sum + String.to_integer(number), remaining}
            {false, remaining} -> {sum, remaining}
          end
        end)

      sum
    end)
    |> Enum.sum()
  end

  def part2(args) do
    lines = String.split(args, "\n", trim: true)

    character_list = Enum.map(lines, &String.split(&1, "", trim: true))

    lines
    |> Enum.with_index()
    |> Enum.reduce(0, fn {line, index}, acc ->
      characters = String.split(line, "", trim: true)
      previous_line = Enum.at(character_list, max(index - 1, 0)) || []
      next_line = Enum.at(character_list, index + 1) || []

      find_gears(characters, characters, previous_line, next_line, "", 0) + acc
    end)
  end

  defp parse_numbers(line) do
    String.split(line, @symbols_and_period, trim: true)
  end

  defp find_gears(
         [symbol | rest] = remaining,
         full_line,
         previous_line,
         next_line,
         previous_char,
         total
       )
       when symbol in @symbols do
    index = -length(remaining)

    total =
      [
        number_before_symbol(full_line, index, previous_char),
        number_after_symbol(rest),
        number_from_adjacent_line(previous_line, index),
        number_from_adjacent_line(next_line, index)
      ]
      |> List.flatten()
      |> add_gears(total)

    # no touching symbols so we can skip next one
    [previous_char | rest] = rest

    find_gears(rest, full_line, previous_line, next_line, previous_char, total)
  end

  defp find_gears([], _full_line, _previous_line, _next_line, _previous_char, total), do: total

  defp find_gears(
         [current_char | rest],
         full_line,
         previous_line,
         next_line,
         _previous_char,
         total
       ) do
    find_gears(rest, full_line, previous_line, next_line, current_char, total)
  end

  defp add_gears([first, second], total) do
    String.to_integer(first) * String.to_integer(second) + total
  end

  defp add_gears(_gears, total), do: total

  defp number_before_symbol(line, index, previous_char) when previous_char in @numbers do
    line |> Enum.slice((index - 3)..(index - 1)) |> parse_number_before_symbol()
  end

  defp number_before_symbol(_line, _index, _previous_char), do: []

  defp number_after_symbol([number | _rest] = after_number) when number in @numbers do
    after_number |> Enum.slice(0..2) |> parse_number_after_symbol()
  end

  defp number_after_symbol(_after_number), do: []

  defp parse_number_before_symbol([first, second, third]) do
    cond do
      first in @numbers and second in @numbers and third in @numbers ->
        first <> second <> third

      second in @numbers and third in @numbers ->
        second <> third

      third in @numbers ->
        third
    end
  end

  defp parse_number_after_symbol([first, second, third]) do
    cond do
      first in @numbers and second in @numbers and third in @numbers ->
        first <> second <> third

      first in @numbers and second in @numbers ->
        first <> second

      first in @numbers ->
        first
    end
  end

  defp number_from_adjacent_line(line, index) do
    [first, second, third] = touching_chars = Enum.slice(line, (index - 1)..(index + 1))

    cond do
      # all symbols
      first in @symbols_and_period and second in @symbols_and_period and
          third in @symbols_and_period ->
        []

      # all numbers
      first in @numbers and second in @numbers and third in @numbers ->
        Enum.join(touching_chars, "")

      first in @numbers and third in @numbers ->
        before_number =
          line |> Enum.slice((index - 3)..(index - 1)) |> parse_number_before_symbol()

        after_number =
          line |> Enum.slice((index + 1)..(index + 3)) |> parse_number_after_symbol()

        [before_number, after_number]

      first in @numbers and second in @numbers ->
        line |> Enum.slice((index - 2)..index) |> parse_number_before_symbol()

      second in @numbers and third in @numbers ->
        line |> Enum.slice(index..(index + 2)) |> parse_number_after_symbol()

      first in @numbers ->
        line |> Enum.slice((index - 3)..(index - 1)) |> parse_number_before_symbol()

      second in @numbers ->
        second

      third in @numbers ->
        line |> Enum.slice((index + 1)..(index + 3)) |> parse_number_after_symbol()
    end
  end

  defp include_number?(
         number,
         [char_before_number | tail] = current_line,
         previous_line,
         next_line
       ) do
    cond do
      List.starts_with?(current_line, number) ->
        [char_after_number | _rest] = remaining = current_line -- number

        include =
          char_after_number in @symbols or
            check_adjacent_line(number, current_line, previous_line) or
            check_adjacent_line(number, current_line, next_line)

        {include, remaining}

      # end of list
      tail == number ->
        include =
          char_before_number in @symbols or
            check_adjacent_line(number, tail, previous_line) or
            check_adjacent_line(number, tail, next_line)

        {include, []}

      List.starts_with?(tail, number) ->
        [char_after_number | _rest] = remaining = tail -- number

        include =
          char_before_number in @symbols or char_after_number in @symbols or
            check_adjacent_line(number, tail, previous_line) or
            check_adjacent_line(number, tail, next_line)

        {include, remaining}

      true ->
        [_head | rest] = current_line
        include_number?(number, rest, previous_line, next_line)
    end
  end

  defp check_adjacent_line(_number, _current_line, []), do: false

  defp check_adjacent_line(number, current_line, adjacent_line) do
    start_range = -length(current_line) - 1
    end_range = min(start_range + length(number) + 1, -1)

    adjacent_line
    |> Enum.slice(start_range..end_range)
    |> Enum.any?(&(&1 in @symbols))
  end
end
