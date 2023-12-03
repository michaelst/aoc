defmodule AdventOfCode.Day03Test do
  use ExUnit.Case

  import AdventOfCode.Day03

  test "part1" do
    input = """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*....1.
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    ......$...
    ....&..620
    """

    result = part1(input)

    assert result == 4981
  end

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

    assert result == 87605697
  end
end
