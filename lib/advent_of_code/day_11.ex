defmodule AdventOfCode.Day11 do
  def part1(args) do
    galaxies = expand_galaxy(args, 2)

    galaxies
    |> Enum.reduce(Map.new(), fn {index, point}, acc ->
      get_paths(acc, index, point, galaxies)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def part2(args, multiplier \\ 1_000_000) do
    galaxies = expand_galaxy(args, multiplier)

    galaxies
    |> Enum.reduce(Map.new(), fn {index, point}, acc ->
      get_paths(acc, index, point, galaxies)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def get_paths(paths, index, galaxy, galaxies) do
    Enum.reduce(galaxies, paths, fn {dest_index, dest}, acc ->
      if dest == galaxy do
        acc
      else
        distance = distance(galaxy, dest)
        map_key = {min(index, dest_index), max(index, dest_index)}
        Map.update(acc, map_key, distance, fn existing -> min(existing, distance) end)
      end
    end)
  end

  def expand_galaxy(args, multiplier) do
    [x_additions | grid_with_additions] =
      args
      |> String.split("\n", trim: true)
      |> Enum.reduce([], fn line, acc ->
        list = String.split(line, "", trim: true)

        if String.contains?(line, "#") do
          [[1 | list] | acc]
        else
          [[multiplier | list] | acc]
        end
      end)
      |> Enum.reverse()
      |> transpose()
      |> Enum.reduce([], fn line, acc ->
        if Enum.member?(line, "#") do
          [[1 | line] | acc]
        else
          [[multiplier | line] | acc]
        end
      end)
      |> reverse_transpose()

    x_additions =
      Enum.reduce(x_additions, [], fn
        _x_addition, [] -> [-1]
        x_addition, [last | _] = offsets -> [x_addition + last | offsets]
      end)
      |> Enum.reverse()

    grid_with_additions
    |> Enum.reduce({[], -1}, fn [y_addition | row], {rows, offset} ->
      {[[offset + y_addition | row] | rows], offset + y_addition}
    end)
    |> then(fn {rows, _} -> rows end)
    |> Enum.reverse()
    |> Enum.map(fn row ->
      [{y, _} | _] = row_with_x = Enum.zip(row, x_additions)

      Enum.map(row_with_x, fn {val, x} ->
        {{x, y}, val}
      end)
    end)
    |> List.flatten()
    |> Enum.filter(fn {_, val} -> val == "#" end)
    |> Enum.with_index()
    |> Enum.map(fn {{point, _}, index} -> {index, point} end)
  end

  def transpose([[] | _]), do: []

  def transpose(list) do
    [Enum.map(list, &hd/1) | transpose(Enum.map(list, &tl/1))]
  end

  def reverse_transpose([[] | _]), do: []

  def reverse_transpose(list) do
    [
      Enum.map(list, &hd/1) |> Enum.reverse()
      | reverse_transpose(Enum.map(list, &tl/1))
    ]
  end

  def distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
end
