import std/[sugar, deques, math, strutils, strformat, sequtils, tables]

type
  Point = tuple
    x: int
    y: int
  OctopusCavern = object
    map: Table[Point, int]
    rows: int
    cols: int
    step: int
    n_flashes: int

proc read_input*(path: string): OctopusCavern =
  ## Parse the input file into a cavern map.
  let
    contents = collect(new_seq):
      for line in read_file(path).split("\n"):
        if line != "": line
    rows = contents.len
    cols = contents[0].len

  var data = init_table[Point, int]()

  for x, line in contents:
    for y, point in line.to_seq():
      data[(x, y)] = parse_int($point)

  return OctopusCavern(map: data, rows: rows, cols: cols)

proc points_to_flash(cavern: OctopusCavern): Deque[Point] =
  ## Return a list of coordinates of points that should be flashed.
  let points = collect(new_seq):
    for (point, energy) in cavern.map.pairs:
      if energy > 9: point

  return points.to_deque()

proc flash(cavern: var OctopusCavern, point: Point) =
  ## Flash a point in the cavern and increase the energy of the adjacent points.
  # Flash the current point
  cavern.n_flashes.inc()
  cavern.map[point] = 0

  # Increase the energy of the nearby points
  for dx in -1..1:
    for dy in -1..1:
      let target = (point.x + dx, point.y + dy)
      if target in cavern.map and cavern.map[target] > 0:
        cavern.map[target].inc()

proc advance_one_step(cavern: var OctopusCavern): int =
  ## Advance one step in the flashing pattern.
  # Increase the step counter
  cavern.step.inc()

  # Increase all the energy points
  for x in 0..<cavern.rows:
    for y in 0..<cavern.cols:
      cavern.map[(x, y)].inc()

  var
    flashes_this_step = 0
    to_flash = cavern.points_to_flash()

  # Flash the octopuses that need so and return the count for this step
  while to_flash.len() > 0:
    flashes_this_step.inc()
    cavern.flash(to_flash.pop_first())
    to_flash = cavern.points_to_flash()

  return flashes_this_step

# proc display_cavern(cavern: OctopusCavern) =
#   ## Display the cavern in a 10x10 grid.
#   for x in 0..<cavern.rows:
#     for y in 0..<cavern.cols:
#       write(stdout, $cavern.map[(x, y)])
#     echo()
#   echo()

proc solve_first_part*(input: OctopusCavern): int =
  ## Solve the first part counting flashes up to the 100th step.
  var cavern = input

  while cavern.step < 100:
    discard cavern.advance_one_step()

  return cavern.n_flashes

proc solve_second_part*(input: OctopusCavern): int =
  ## Solve the second part finding the first step when every point flashes.
  var
    cavern = input
    last_step_flashes = 0

  while last_step_flashes < 100:
    last_step_flashes = cavern.advance_one_step()

  return cavern.step

proc solve*(path: string) =
  ## Solve the Day 11 problem and output
  var input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
