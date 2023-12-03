defmodule AdventOfCode.Day03 do
  @symbols ["*", "#", "-", "+", "@", "%", "&", "=", "$", "/"]
  def part1(args) do
    lines = String.split(args, "\n", trim: true)

    character_list = Enum.map(lines, &String.split(&1, "", trim: true))

    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, index} ->
      characters = String.split(line, "", trim: true)
      previous_line = Enum.at(character_list, max(index - 1, 0)) || []
      next_line = Enum.at(character_list, index + 1) || []

      numbers = String.split(line, ["." | @symbols], trim: true)

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
    args
    |> String.split("\n", trim: true)
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
