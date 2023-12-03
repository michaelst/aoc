defmodule Mix.Tasks.D03.P2 do
  use Mix.Task

  alias AdventOfCode.Day03
  alias AdventOfCode.Day03A

  @shortdoc "Day 03 Part 2"
  def run(args) do
    input = File.read!("input/day03")

    if Enum.member?(args, "-b"),
      do:
        Benchee.run(%{
          part_2: fn -> input |> Day03.part2() end,
          part_2_a: fn -> input |> Day03A.part2() end
        }),
      else:
        input
        |> Day03.part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
