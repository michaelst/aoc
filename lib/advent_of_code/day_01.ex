defmodule AdventOfCode.Day01 do
  def part1(args) do
    Enum.reduce(args, 0, fn string, acc ->
      [first_digit | _rest] = number = get_digits(string)
      last_digit = List.last(number)

      acc + first_digit * 10 + last_digit
    end)
  end

  def part2(args) do
    Enum.reduce(args, 0, fn string, acc ->
      codepoints = String.codepoints(string)
      first_digit = check_codepoints(codepoints)
      last_digit = codepoints |> Enum.reverse() |> check_codepoints()

      acc + first_digit * 10 + last_digit
    end)
  end

  defp check_codepoints(["1" | _rest]), do: 1
  defp check_codepoints(["2" | _rest]), do: 2
  defp check_codepoints(["3" | _rest]), do: 3
  defp check_codepoints(["4" | _rest]), do: 4
  defp check_codepoints(["5" | _rest]), do: 5
  defp check_codepoints(["6" | _rest]), do: 6
  defp check_codepoints(["7" | _rest]), do: 7
  defp check_codepoints(["8" | _rest]), do: 8
  defp check_codepoints(["9" | _rest]), do: 9
  defp check_codepoints(["o", "n", "e" | _rest]), do: 1
  defp check_codepoints(["e", "n", "o" | _rest]), do: 1
  defp check_codepoints(["t", "w", "o" | _rest]), do: 2
  defp check_codepoints(["o", "w", "t" | _rest]), do: 2
  defp check_codepoints(["t", "h", "r", "e", "e" | _rest]), do: 3
  defp check_codepoints(["e", "e", "r", "h", "t" | _rest]), do: 3
  defp check_codepoints(["f", "o", "u", "r" | _rest]), do: 4
  defp check_codepoints(["r", "u", "o", "f" | _rest]), do: 4
  defp check_codepoints(["f", "i", "v", "e" | _rest]), do: 5
  defp check_codepoints(["e", "v", "i", "f" | _rest]), do: 5
  defp check_codepoints(["s", "i", "x" | _rest]), do: 6
  defp check_codepoints(["x", "i", "s" | _rest]), do: 6
  defp check_codepoints(["s", "e", "v", "e", "n" | _rest]), do: 7
  defp check_codepoints(["n", "e", "v", "e", "s" | _rest]), do: 7
  defp check_codepoints(["e", "i", "g", "h", "t" | _rest]), do: 8
  defp check_codepoints(["t", "h", "g", "i", "e" | _rest]), do: 8
  defp check_codepoints(["n", "i", "n", "e" | _rest]), do: 9
  defp check_codepoints(["e", "n", "i", "n" | _rest]), do: 9
  defp check_codepoints([_head | tail]), do: check_codepoints(tail)

  defp get_digits(string) do
    string |> String.replace(~r/[^\d]/, "") |> String.to_integer() |> Integer.digits()
  end
end
