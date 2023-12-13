defmodule AdventOfCode.Day13Test do
  use ExUnit.Case

  import AdventOfCode.Day13

  test "part1" do
    input = """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#
    """

    result = part1(input)

    assert result == 405

    input = File.read!("input/day13")

    result = part1(input)

    assert result == 27202
  end

  test "part2" do
    input = """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#
    """

    result = part2(input)

    assert result == 400

    input = File.read!("input/day13")

    result = part2(input)

    assert result == 41566
  end
end
