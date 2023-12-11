defmodule AdventOfCode.Day11Test do
  use ExUnit.Case

  import AdventOfCode.Day11

  test "part1" do
    input = """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """

    result = part1(input)

    assert result == 374
  end

  test "expand galaxy" do
    input = """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """

    result = expand_galaxy(input, 2)

    assert result == [
             {0, {4, 0}},
             {1, {9, 1}},
             {2, {0, 2}},
             {3, {8, 5}},
             {4, {1, 6}},
             {5, {12, 7}},
             {6, {9, 10}},
             {7, {0, 11}},
             {8, {5, 11}}
           ]
  end

  test "part2" do
    input = """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """

    result = part2(input, 10)

    assert result == 1030

    result = part2(input, 100)

    assert result == 8410
  end
end
