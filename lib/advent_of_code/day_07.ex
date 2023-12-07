defmodule AdventOfCode.Day07 do
  def part1(args) do
    String.split(args, "\n", trim: true)
    |> Enum.map(fn line ->
      [cards, bid] = String.split(line, " ", trim: true)
      bid = String.to_integer(bid)
      cards = String.split(cards, "", trim: true) |> Enum.map(&number/1)

      number_of_cards = Enum.group_by(cards, & &1) |> Enum.map(fn {_k, v} -> length(v) end)

      {cards, number_of_cards, bid}
    end)
    |> Enum.map(fn {cards, grouped_cards, bid} ->
      {[0 | cards], bid, score(grouped_cards)}
    end)
    |> Enum.sort_by(fn {cards, _bid, score} -> {score, cards} end)
    |> Enum.with_index()
    |> Enum.map(fn {{_cards, bid, _score}, index} ->
      bid * (index + 1)
    end)
    |> Enum.sum()
  end

  def part2(args) do
    String.split(args, "\n", trim: true)
    |> Enum.map(fn line ->
      [cards, bid] = String.split(line, " ", trim: true)
      bid = String.to_integer(bid)
      cards = String.split(cards, "", trim: true) |> Enum.map(&joker_number/1)

      number_of_cards =
        Enum.group_by(cards, & &1)
        |> Enum.map(fn {k, v} -> {k, length(v)} end)
        |> Enum.sort_by(&elem(&1, 1))
        |> Enum.reverse()

      {cards, number_of_cards, bid}
    end)
    |> Enum.map(fn {cards, grouped_cards, bid} ->
      {[0 | cards], bid, grouped_cards |> maybe_change_jokers() |> score()}
    end)
    |> Enum.sort_by(fn {cards, _bid, score} -> {score, cards} end)
    |> Enum.with_index()
    |> Enum.map(fn {{_cards, bid, _score}, index} ->
      bid * (index + 1)
    end)
    |> Enum.sum()
  end

  defp joker_number("J"), do: 1
  defp joker_number(number), do: number(number)

  defp number("A"), do: 14
  defp number("K"), do: 13
  defp number("Q"), do: 12
  defp number("J"), do: 11
  defp number("T"), do: 10
  defp number(number), do: String.to_integer(number)

  # 7 Five of a kind, where all five cards have the same label: AAAAA
  defp score(cards) when length(cards) == 1, do: 7

  defp score(cards) when length(cards) == 2 do
    if Enum.max(cards) == 4 do
      # 6 Four of a kind, where four cards have the same label and one card has a different label: AA8AA
      6
    else
      # 5 Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
      5
    end
  end

  defp score(cards) when length(cards) == 3 do
    case Enum.max(cards) do
      # 4 Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
      3 ->
        4

      2 ->
        Enum.filter(cards, &(&1 == 2))
        |> length()
        |> case do
          # 3 Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
          2 -> 3
          # 2 One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
          1 -> 2
        end
    end
  end

  # 2 One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
  defp score(cards) when length(cards) == 4, do: 2

  # 1 High card, where all cards' labels are distinct: 23456
  defp score(cards) when length(cards) == 5, do: 1

  defp maybe_change_jokers([{card, most} | rest] = cards) do
    cards
    |> Enum.find(fn {card, count} -> card == 1 && count end)
    |> case do
      nil ->
        cards

      {1, 5} ->
        [{1, 5}]

      {1, count} when card == 1 ->
        [{card, most} | rest] = rest
        [{card, most + count} | rest]

      {_, count} ->
        [{card, most + count} | Enum.filter(rest, fn {card, _} -> card != 1 end)]
    end
    |> Enum.map(&elem(&1, 1))
  end
end
