defmodule AdventOfCode.Day16 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {val, x} ->
        {{x, y}, {val, false}}
      end)
    end)
    |> List.flatten()
    |> Map.new()
    |> find_path({0, 0}, {-1, 0})
    |> then(fn {grid, _} -> grid end)
    |> Enum.filter(fn {_key, {_value, energized}} -> energized end)
    |> Enum.count()
  end

  def part2(args) do
    rows = String.split(args, "\n", trim: true)
    line_length = String.length(hd(rows))

    grid =
      args
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {row, y} ->
        row
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.map(fn {val, x} ->
          {{x, y}, {val, false}}
        end)
      end)
      |> List.flatten()
      |> Map.new()

    Enum.flat_map(0..(line_length - 1), fn i ->
      [
        {{0, i}, {-1, i}},
        {{line_length - 1, i}, {line_length, i}},
        {{i, 0}, {i, -1}},
        {{i, line_length - 1}, {i, line_length}}
      ]
    end)
    |> Task.async_stream(fn {{x, y}, {prev_x, prev_y}} ->
      grid
      |> find_path({x, y}, {prev_x, prev_y})
      |> then(fn {grid, _} -> grid end)
      |> Enum.filter(fn {_key, {_value, energized}} -> energized end)
      |> Enum.count()
    end)
    |> Stream.map(fn {:ok, result} -> result end)
    |> Enum.max()
  end

  def find_path(grid, {x, y}, {prev_x, prev_y}, already_traveled \\ %{}) do
    direction = direction({x, y}, {prev_x, prev_y})
    traveled_key = {{x, y}, direction}

    if Map.has_key?(grid, {x, y}) and not Map.has_key?(already_traveled, traveled_key) do
      {value, _} = Map.get(grid, {x, y})
      # mark spot as energized and traveled
      grid = Map.put(grid, {x, y}, {value, true})
      next_path = next_path(value, direction, {x, y})
      already_traveled = Map.put(already_traveled, traveled_key, true)

      Enum.reduce(next_path, {grid, already_traveled}, fn {nx, ny},
                                                          {grid_acc, already_traveled_acc} ->
        find_path(grid_acc, {nx, ny}, {x, y}, already_traveled_acc)
      end)
    else
      {grid, already_traveled}
    end
  end

  def direction({x, y}, {prev_x, prev_y}) do
    case {x - prev_x, y - prev_y} do
      {0, -1} -> :up
      {0, 1} -> :down
      {-1, 0} -> :left
      {1, 0} -> :right
    end
  end

  def next_path(".", :up, {x, y}), do: [{x, y - 1}]
  def next_path("|", :up, {x, y}), do: [{x, y - 1}]
  def next_path("-", :up, {x, y}), do: [{x - 1, y}, {x + 1, y}]
  def next_path("/", :up, {x, y}), do: [{x + 1, y}]
  def next_path("\\", :up, {x, y}), do: [{x - 1, y}]
  def next_path(".", :down, {x, y}), do: [{x, y + 1}]
  def next_path("|", :down, {x, y}), do: [{x, y + 1}]
  def next_path("-", :down, {x, y}), do: [{x - 1, y}, {x + 1, y}]
  def next_path("/", :down, {x, y}), do: [{x - 1, y}]
  def next_path("\\", :down, {x, y}), do: [{x + 1, y}]
  def next_path(".", :left, {x, y}), do: [{x - 1, y}]
  def next_path("|", :left, {x, y}), do: [{x, y + 1}, {x, y - 1}]
  def next_path("-", :left, {x, y}), do: [{x - 1, y}]
  def next_path("/", :left, {x, y}), do: [{x, y + 1}]
  def next_path("\\", :left, {x, y}), do: [{x, y - 1}]
  def next_path(".", :right, {x, y}), do: [{x + 1, y}]
  def next_path("|", :right, {x, y}), do: [{x, y + 1}, {x, y - 1}]
  def next_path("-", :right, {x, y}), do: [{x + 1, y}]
  def next_path("/", :right, {x, y}), do: [{x, y - 1}]
  def next_path("\\", :right, {x, y}), do: [{x, y + 1}]
end
