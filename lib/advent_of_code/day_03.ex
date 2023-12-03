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

      find_gears(characters, characters, previous_line, next_line, 0) + acc
    end)
  end

  defp parse_numbers(line) do
    String.split(line, @symbols_and_period, trim: true)
  end

  defp find_gears([symbol | rest] = remaining, full_line, previous_line, next_line, total)
       when symbol in @symbols do
    index = -length(remaining)

    total =
      [
        number_before_symbol(full_line, index),
        number_after_symbol(full_line, index),
        number_from_adjacent_line(previous_line, index),
        number_from_adjacent_line(next_line, index)
      ]
      |> List.flatten()
      |> add_gears(total)

    find_gears(rest, full_line, previous_line, next_line, total)
  end

  defp find_gears([], _full_line, _previous_line, _next_line, total), do: total

  defp find_gears([_head | rest], full_line, previous_line, next_line, total) do
    find_gears(rest, full_line, previous_line, next_line, total)
  end

  defp add_gears([first, second], total) do
    String.to_integer(first) * String.to_integer(second) + total
  end

  defp add_gears(_gears, total), do: total

  defp number_before_symbol(line, index) do
    chars_before_number = Enum.slice(line, (index - 3)..(index - 1)) |> IO.inspect

    if List.last(chars_before_number) in @numbers do
      chars_before_number |> Enum.join("") |> parse_numbers() |> List.last()
    else
      []
    end
  end

  defp number_after_symbol(line, index) do
    [next_char | _rest] = chars_after_number = Enum.slice(line, (index + 1)..(index + 3))

    if next_char in @numbers do
      chars_after_number |> Enum.join("") |> parse_numbers() |> List.first()
    else
      []
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
          line |> Enum.slice((index - 4)..(index - 1)) |> Enum.join("") |> parse_numbers() |> List.last()

        after_number =
          line |> Enum.slice((index + 1)..(index + 3)) |> Enum.join("") |> parse_numbers() |> List.first()

        [before_number, after_number]

      first in @numbers and second in @numbers ->
        line |> Enum.slice(0..index) |> Enum.join("") |> parse_numbers() |> List.last()

      second in @numbers and third in @numbers ->
        line |> Enum.slice(index..-1) |> Enum.join("") |> parse_numbers() |> List.first()

      first in @numbers ->
        line |> Enum.slice((index - 4)..(index - 1)) |> Enum.join("") |> parse_numbers() |> List.last()

      second in @numbers ->
        second

      third in @numbers ->
        line |> Enum.slice((index + 1)..(index + 3)) |> Enum.join("") |> parse_numbers() |> List.first()
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
