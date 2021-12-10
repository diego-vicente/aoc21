import std/[sugar, algorithm, math, options, sets, strutils, strformat,
    sequtils, tables]

import fusion/matching

{.experimental: "caseStmtMacros".}

type
  Direction = enum North, East, South, West
  Point = tuple
    x: int
    y: int
  Neighbor = tuple
    height: int
    direction: Direction
  HeightMap = object
    data: seq[int]
    rows: int
    cols: int

proc `[]`(hmap: HeightMap, x, y: int): Option[int] =
  ## Access a HeightMap with a two dimensional index.
  if 0 <= x and x < hmap.rows and 0 <= y and y < hmap.cols:
    some(hmap.data[x * hmap.cols + y])
  else:
    none(int)

proc read_input*(path: string): HeightMap =
  ## Parse the input file into a height map.
  let
    contents = collect(new_seq):
      for line in read_file(path).split("\n"):
        if line != "":
          line
    rows = contents.len
    cols = contents[0].len
    data = collect(new_seq):
      for line in contents:
        for point in line.to_seq():
          parse_int($point)

  return HeightMap(data: data, rows: rows, cols: cols)

proc get_neighbors(hmap: HeightMap, x, y: int): seq[Neighbor] =
  ## Get a list of valid neighbors for a given point.
  let
    candidates = @[
      (North, (-1, 0)),
      (East, (0, 1)),
      (South, (1, 0)),
      (West, (0, -1))
    ]
    neighbors = collect(new_seq):
      for (direction, delta) in candidates:
        let neighbor = hmap[x + delta[0], y + delta[1]]
        if neighbor.is_some:
          (neighbor.get(), direction)

  return neighbors

proc get_low_points(hmap: HeightMap): seq[Point] =
  ## Return a list of low point coordinates for a given map.
  collect(new_seq):
    for x in 0..<hmap.rows:
      for y in 0..<hmap.cols:
        let
          current = hmap[x, y].get()
          neighbors = hmap.get_neighbors(x, y)
          is_low_point = neighbors.all(
            proc (n: Neighbor): bool = current < n.height
          )

        if is_low_point:
          (x, y)

proc low_points_risk(hmap: HeightMap): int =
  ## Return the total low point risk for a height map.
  let risks = collect(new_seq):
    for (x, y) in hmap.get_low_points():
      1 + hmap[x, y].get()

  return sum(risks)

proc height_cmp(x, y: Neighbor): int =
  ## When comparing neighbors, sort by height.
  cmp(x.height, y.height)

proc find_related_basin(hmap: HeightMap,
                        x, y: int,
                        basin_map: var Table[Point, Point],
                        low_points: HashSet[Point]): Point =
  ## For a given point, return the low point he is related to.
  ##
  ## The complexity of the task is high, so this function uses a combination of
  ## recursive calling and dynamic programming, memoizing all points already
  ## explored in order to not explore any twice. This results in some awkward
  ## parameter passing, but also ensures that the basin_map updates the whole
  ## trajectory to the low point, not only the point itself (making the task
  ## much faster).
  # If the point is a low point, return it
  if (x, y) in low_points:
    return (x, y)

  # If the point has already been explored, return it.
  if (x, y) in basin_map:
    return basin_map[(x, y)]

  # Otherwise, traverse to the next point downstream.
  let
    neighbors = hmap.get_neighbors(x, y)
    downstream = neighbors.sorted(height_cmp)

  var basin: Point

  # Define the next recursion step
  case downstream[0].direction
  of North: basin = hmap.find_related_basin(x - 1, y, basin_map, low_points)
  of East: basin = hmap.find_related_basin(x, y + 1, basin_map, low_points)
  of West: basin = hmap.find_related_basin(x, y - 1, basin_map, low_points)
  of South: basin = hmap.find_related_basin(x + 1, y, basin_map, low_points)

  # Update the basin map, in order to perform complete memoization
  basin_map[(x, y)] = basin
  return basin

proc point_to_basin_relation(hmap: HeightMap): Table[Point, Point] =
  ## Generate the map relating each to point to its basin.
  let low_points = hmap.get_low_points().to_hash_set()

  var basin_map = init_table[Point, Point]()
  for x in 0..<hmap.rows:
    for y in 0..<hmap.cols:
      if hmap[x, y].get() < 9:
        basin_map[(x, y)] = hmap.find_related_basin(x, y, basin_map, low_points)

  return basin_map

proc solve_first_part*(input: HeightMap): int =
  ## Solve the first part using the low point risk.
  input.low_points_risk()

proc solve_second_part*(input: HeightMap): int =
  ## Solve the second part counting the basin sizes.
  let
    basin_map = input.point_to_basin_relation()
    basin_sizes = to_count_table(basin_map.values.to_seq())
    top_basins = basin_sizes.values.to_seq.sorted(Descending)[0..2]

  return top_basins.prod()

proc solve*(path: string) =
  ## Solve the Day 09 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
