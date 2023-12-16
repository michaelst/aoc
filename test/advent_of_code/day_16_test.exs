defmodule AdventOfCode.Day16Test do
  use ExUnit.Case

  import AdventOfCode.Day16

  test "part1" do
    input = File.read!("input/day16_test")

    result = part1(input)

    assert result == 46
  end

  test "part2" do
    input = File.read!("input/day16_test")
    result = part2(input)

    assert result == 51

    input = File.read!("input/day16")
    result = part2(input)

    assert result == 8318
  end
end
