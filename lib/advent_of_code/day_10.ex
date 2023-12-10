defmodule AdventOfCode.Day10 do
  require Integer

  def part1(args) do
    grid = create_grid(args)

    starting_point = grid |> Enum.find(fn {_, val} -> val == "S" end) |> elem(0)

    grid = Map.delete(grid, starting_point)

    costs = grid |> Enum.map(&{elem(&1, 0), :infinity}) |> Map.new()
    {first_starting_point, second_starting_point} = starting_points(grid, starting_point)

    first_loop =
      dijkstras(
        [{first_starting_point, 1}],
        grid,
        costs,
        &get_neighbors/2
      )
      |> Enum.filter(&(elem(&1, 1) != :infinity))

    second_loop =
      dijkstras(
        [{second_starting_point, 1}],
        grid,
        costs,
        &get_neighbors/2
      )
      |> Enum.filter(&(elem(&1, 1) != :infinity))
      |> Map.new()

    Enum.map(first_loop, fn {point, cost} ->
      min(cost, Map.get(second_loop, point, 0))
    end)
    |> Enum.max()
  end

  def part2(args) do
    grid = create_grid(args)

    starting_point = grid |> Enum.find(fn {_, val} -> val == "S" end) |> elem(0)

    costs = grid |> Enum.map(&{elem(&1, 0), :infinity}) |> Map.new()

    {first_starting_point, _second_starting_point} =
      starting_points(grid, starting_point)

    loop =
      dijkstras(
        [{first_starting_point, 1}],
        Map.delete(grid, starting_point),
        costs,
        &get_neighbors/2
      )
      |> Enum.filter(&(elem(&1, 1) != :infinity))
      |> Enum.map(&elem(&1, 0))

    full_loop =
      MapSet.new([starting_point, first_starting_point | loop])

    grid
    |> Enum.map(&elem(&1, 0))
    |> Enum.reject(&MapSet.member?(full_loop, &1))
    |> check_points(full_loop, grid)
  end

  def check_points(points, full_loop, grid, count \\ 0)
  def check_points([], _full_loop, _grid, count), do: count

  def check_points([point | points], full_loop, grid, count) do
    if in_loop?(point, full_loop, grid) do
      check_points(points, full_loop, grid, count + 1)
    else
      check_points(points, full_loop, grid, count)
    end
  end

  def in_loop?({x, y}, full_loop, grid) do
    left_line = Enum.map(0..(x - 1), fn nx -> {nx, y} end) |> MapSet.new()

    with true <-
           MapSet.intersection(full_loop, left_line)
           |> Enum.map(&Map.get(grid, &1))
           |> Enum.count(&(&1 in ["|", "L", "J"]))
           |> Integer.is_odd() do
      right_line = Enum.map((x + 1)..139, fn nx -> {nx, y} end) |> MapSet.new()

      MapSet.intersection(full_loop, right_line)
      |> Enum.map(&Map.get(grid, &1))
      |> Enum.count(&(&1 in ["|", "L", "J"]))
      |> Integer.is_odd()
    end
  end

  def create_grid(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {val, x} ->
        {{x, y}, val}
      end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def starting_points(grid, {x, y}) do
    [first, second] =
      get_adj(grid, {x, y}, [
        # above
        {0, -1},
        # below
        {0, 1},
        # left
        {-1, 0},
        # right
        {1, 0}
      ])
      |> Enum.filter(fn {px, py} ->
        value = Map.get(grid, {px, py})

        case {px - x, py - y} do
          # above
          {0, -1} -> value in ["7", "F", "|"]
          # below
          {0, 1} -> value in ["|", "L", "J"]
          # left
          {-1, 0} -> value in ["L", "F", "-"]
          # right
          {1, 0} -> value in ["7", "J", "-"]
        end
      end)

    {first, second}
  end

  def get_neighbors(map, {x, y}) do
    above = {0, -1}
    below = {0, 1}
    left = {-1, 0}
    right = {1, 0}

    deltas =
      case Map.get(map, {x, y}) do
        "-" -> [left, right]
        "|" -> [above, below]
        "L" -> [above, right]
        "J" -> [above, left]
        "7" -> [left, below]
        "F" -> [right, below]
        _ -> []
      end

    get_adj(map, {x, y}, deltas)
  end

  def get_adj(map, {x, y}, deltas) do
    Enum.reduce(deltas, [], fn {dx, dy}, acc ->
      new_point = {x + dx, y + dy}

      if Map.has_key?(map, new_point) do
        [new_point | acc]
      else
        acc
      end
    end)
  end

  def dijkstras([], _unvisited, costs, _get_neighbors) do
    costs
  end

  def dijkstras(queue, unvisited, costs, get_neighbors) do
    [{node, cost} | rest_queue] = queue

    if unvisited == %{} do
      cost
    else
      neighbors = get_neighbors.(unvisited, node)

      {new_queue, new_costs} =
        Enum.reduce(neighbors, {rest_queue, costs}, fn point, {queue_acc, costs_acc} ->
          new_cost = cost + 1

          if new_cost < Map.get(costs, point) do
            {
              [{point, new_cost} | queue_acc],
              Map.put(costs_acc, point, new_cost)
            }
          else
            {queue_acc, costs_acc}
          end
        end)

      dijkstras(
        Enum.sort(new_queue),
        Map.delete(unvisited, node),
        new_costs,
        get_neighbors
      )
    end
  end
end
