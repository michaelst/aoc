defmodule AdventOfCode.Day08 do
  def part1(args) do
    [instructions | maps] = String.split(args, "\n", trim: true)

    instructions = String.split(instructions, "", trim: true)

    maps =
      Enum.map(maps, fn map ->
        [source, destination] = String.split(map, " = ", trim: true)

        [left, right] =
          String.replace(destination, ["(", ")"], "") |> String.split(", ", trim: true)

        {source, {left, right}}
      end)

    calculate_steps("AAA", :full, Map.new(maps), instructions, instructions)
  end

  def part2(args) do
    [instructions | maps] = String.split(args, "\n", trim: true)

    instructions = String.split(instructions, "", trim: true)

    maps =
      Enum.map(maps, fn map ->
        <<source::binary-3, " = (", left::binary-3, ", ", right::binary-3, ")">> = map

        {source, {left, right}}
      end)

    maps
    |> nodes_ending_in_a()
    |> Task.async_stream(&calculate_steps(&1, :end, Map.new(maps), instructions, instructions))
    |> Enum.map(fn {:ok, result} -> result end)
    |> lcm()
  end

  defp calculate_steps(map_key, pattern, maps, instructions, full_instructions, steps \\ 0)

  defp calculate_steps("ZZZ", :full, _maps, _instructions, _full_instructions, steps),
    do: steps

  defp calculate_steps(
         <<_::binary-2, "Z">>,
         :end,
         _maps,
         _instructions,
         _full_instructions,
         steps
       ),
       do: steps

  defp calculate_steps(map_key, pattern, maps, [], full_instructions, steps) do
    calculate_steps(map_key, pattern, maps, full_instructions, full_instructions, steps)
  end

  defp calculate_steps(
         map_key,
         pattern,
         maps,
         [next_instruction | instructions],
         full_instructions,
         steps
       ) do
    next =
      Map.get(maps, map_key)
      |> get_next(next_instruction)

    calculate_steps(next, pattern, maps, instructions, full_instructions, steps + 1)
  end

  defp get_next({left, _right}, "L"), do: left
  defp get_next({_left, right}, "R"), do: right

  defp nodes_ending_in_a(maps) do
    Enum.filter(maps, fn
      {<<_::binary-2, "A">>, _destinations} -> true
      _ -> false
    end)
    |> Enum.map(&elem(&1, 0))
  end

  defp lcm([a, b]), do: lcm(a, b)
  defp lcm([a | rest]), do: lcm(a, lcm(rest))
  defp lcm(0, 0), do: 0
  defp lcm(a, b), do: (a * b) |> Integer.floor_div(Integer.gcd(a, b))
end
