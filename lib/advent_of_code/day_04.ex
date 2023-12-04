defmodule AdventOfCode.Day04 do
  def part1(args) do
    lines = String.split(args, "\n", trim: true)

    Enum.map(lines, fn line ->
      [_card, winning, mine] = String.split(line, [":", "|"], trim: true)
      winning = String.split(winning, " ", trim: true)
      mine = String.split(mine, " ", trim: true)

      matches = Enum.filter(mine, &(&1 in winning))

      score(length(matches))
    end)
    |> Enum.sum()
  end

  def part2(args) do
    lines = String.split(args, "\n", trim: true)

    Enum.reduce(lines, Map.new(), fn line, acc ->
      ["Card" <> card, winning, mine] = String.split(line, [":", "|"], trim: true)
      card = card |> String.trim() |> String.to_integer()
      winning = String.split(winning, " ", trim: true)
      mine = String.split(mine, " ", trim: true)

      matches = Enum.filter(mine, &(&1 in winning))

      copies = acc[card] || 0

      update_card_counts(acc, card, matches, 0, copies)
    end)
    |> Enum.reduce(0, fn {_card, count}, acc -> acc + count end)
  end

  defp score(0), do: 0
  defp score(1), do: 1
  defp score(count), do: 2 ** (count - 1)

  defp update_card_counts(counts, card, [], 0, _copies) do
    Map.update(counts, card, 1, fn count -> count + 1 end)
  end

  defp update_card_counts(counts, _card, [], _i, _copies), do: counts

  defp update_card_counts(counts, card, matches, 0, copies) do
    Map.update(counts, card, 1, fn count -> count + 1 end)
    |> update_card_counts(card, matches, 1, copies)
  end

  defp update_card_counts(counts, card, [_head | tail], i, copies) do
    Map.update(counts, card + i, copies + 1, fn count -> count + copies + 1 end)
    |> update_card_counts(card, tail, i + 1, copies)
  end
end
