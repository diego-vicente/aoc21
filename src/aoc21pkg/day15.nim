import std/[sugar, heapqueue, strutils, strformat, sequtils, tables]

type
  Point = tuple
    x: int
    y: int
  ScoredPoint = object
    point: Point
    cost: float
  CaveMap = Table[Point, int]

proc read_input*(path: string): CaveMap =
  ## Parse the input file into a cave map.
  collect:
    for y, line in read_file(path).split("\n").pairs():
      if line != "":
        for x, risk in line:
          {(x, y): ($risk).parse_int()}

proc `<`(a, b: ScoredPoint): bool =
  ## Custom function to use in the priority queue.
  a.cost < b.cost

proc manhattan_distance(a, b: Point): int =
  ## Return the Manhattan distance between two points.
  abs(a.x - b.x) + abs(a.y - b.y)

proc get_neighbors(cave: CaveMap, point: Point): seq[Point] =
  ## Return all possible neighbors for a given point.
  let
    deltas = @[(1, 0), (0, 1), (-1, 0), (0, -1)]
    neighbors = collect:
      for (dx, dy) in deltas:
        let candidate = (point.x + dx, point.y + dy)
        if candidate in cave: candidate

  return neighbors

proc a_star(cave: CaveMap): int =
  ## Perform an A* search from start to end in a given map.
  let
    start = (0, 0)
    finish = (
      cave.keys.to_seq.map_it(it[0]).max(),
      cave.keys.to_seq.map_it(it[1]).max()
    )

  var
    open_set = init_heap_queue[ScoredPoint]()
    known_risk = collect:
      for point, _ in cave:
        {point: Inf}

  open_set.push(ScoredPoint(point: start))
  known_risk[start] = 0

  while open_set.len > 0:
    let point = open_set.pop().point

    if point == finish:
      break

    for neighbor in cave.get_neighbors(point):
      let new_risk = known_risk[point] + cave[neighbor].float()
      if new_risk < known_risk[neighbor]:
        known_risk[neighbor] = new_risk
        open_set.push(ScoredPoint(
          point: neighbor,
          cost: new_risk + manhattan_distance(neighbor, finish).float()
        ))

  return known_risk[finish].int()

proc solve_first_part*(input: CaveMap): int =
  ## Solve the search for the given input.
  return a_star(input)

proc increase(cave: CaveMap, times: int = 5): CaveMap =
  ## Increase the map 5 times in each direction.
  let
    x_max = cave.keys.to_seq.map_it(it[0]).max() + 1
    y_max = cave.keys.to_seq.map_it(it[1]).max() + 1

  var total_map = init_table[Point, int]()

  for (point, risk) in cave.pairs:
    for times_x in 0..<times:
      for times_y in 0..<times:
        let
          new_point = (point.x + times_x * x_max, point.y + times_y * y_max)
          new_risk = (((risk - 1) + times_y + times_x) mod 9) + 1
        total_map[new_point] = new_risk

  return total_map

proc solve_second_part*(input: CaveMap): int =
  ## Solve the search for the increased input.
  let total_map = input.increase()
  return a_star(total_map)

proc solve*(path: string) =
  ## Solve the Day 15 problem and output
  var input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
