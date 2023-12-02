defmodule AdventOfCode.Day02 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn game, acc ->
      case game_possible?(game) do
        {number, true} -> acc + String.to_integer(number)
        _not -> acc
      end
    end)
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn game, acc ->
      %{red: red, green: green, blue: blue} = colors_for_game(game)

      red * green * blue + acc
    end)
  end

  defp game_possible?(game) do
    ["Game " <> number, cubes] = String.split(game, ":", parts: 2, trim: true)

    {number,
     cubes
     |> String.split(";", trim: true)
     |> Enum.all?(&round_possible?/1)}
  end

  defp round_possible?(round) do
    round
    |> String.split(" ", trim: true)
    |> parse(%{red: 0, green: 0, blue: 0})
    |> possible?()
  end

  defp possible?(%{red: red, green: green, blue: blue}) do
    red <= 12 and green <= 13 and blue <= 14
  end

  defp colors_for_game(game) do
    ["Game " <> _number, cubes] = String.split(game, ":", parts: 2, trim: true)

    cubes
    |> String.split(";", trim: true)
    |> Enum.reduce(%{red: 0, green: 0, blue: 0}, fn round, colors ->
      round
      |> String.split(" ", trim: true)
      |> parse(colors)
    end)
  end

  defp parse([], colors), do: colors

  defp parse([number, "red" <> _comma | rest], colors),
    do: parse(rest, update_counts(colors, :red, String.to_integer(number)))

  defp parse([number, "blue" <> _comma | rest], colors),
    do: parse(rest, update_counts(colors, :blue, String.to_integer(number)))

  defp parse([number, "green" <> _comma | rest], colors),
    do: parse(rest, update_counts(colors, :green, String.to_integer(number)))

  defp update_counts(colors, color, number) do
    if colors[color] > number do
      colors
    else
      Map.put(colors, color, number)
    end
  end
end
