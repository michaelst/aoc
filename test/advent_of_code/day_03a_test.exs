defmodule AdventOfCode.Day03ATest do
  use ExUnit.Case

  import AdventOfCode.Day03A

  test "part2" do
    input = """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """

    result = part2(input)

    assert result == 467_835

    input = File.read!("input/day03")

    result = part2(input)

    assert result == 87_605_697
  end
end
