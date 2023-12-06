defmodule AdventOfCode.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Day06

  test "part1" do
    input = """
    Time:      7  15   30
    Distance:  9  40  200
    """

    result = part1(input)

    assert result == 288
  end

  test "part2" do
    input = """
    Time:      7  15   30
    Distance:  9  40  200
    """

    result = part2(input)

    assert result == 71503

    input = File.read!("input/day06")

    result = part2(input)

    assert result == 27_102_791
  end
end
