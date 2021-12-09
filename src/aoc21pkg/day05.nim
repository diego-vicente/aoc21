import std/[sugar, strutils, strformat, sequtils, tables]

type
  Point = object
    x: int
    y: int
  Vent = object
    min: Point
    max: Point


proc `<`(a, b: Point): bool =
  if a.x == b.x:
    return a.y < b.y
  else:
    return a.x < b.x

proc read_input*(path: string): seq[Vent] =
  ## Parse the input file into a sequence of Vent
  collect(new_seq):
    for line in read_file(path).split("\n"):
      if line != "":
        let
          coords = line.split(" -> ").map_it(it.split(",").map_it(parse_int(it)))
          point_a = Point(x: coords[0][0], y: coords[0][1])
          point_b = Point(x: coords[1][0], y: coords[1][1])

        if point_a < point_b:
          Vent(min: point_a, max: point_b)
        else:
          Vent(min: point_b, max: point_a)


iterator count_both(a, b: int): int =
  ## Count both up or down from a to b.
  if a < b:
    for x in countup(a, b):
      yield x
  else:
    for x in countdown(a, b):
      yield x

proc count_vent_overlaps(input: seq[Vent]): CountTable[Point] =
  ## Count how many overlaps are defined in a sequence of Vent.
  var floor = initCountTable[Point]()

  for vent in input:
    if vent.min.x == vent.max.x:
      for y in vent.min.y .. vent.max.y:
        floor.inc(Point(x: vent.min.x, y: y))

    elif vent.min.y == vent.max.y:
      for x in vent.min.x .. vent.max.x:
        floor.inc(Point(x: x, y: vent.min.y))

    else:
      for offset in count_both(0, vent.max.y - vent.min.y):
        # The offset must be absolute in the x-axis (since it is already
        # sorted), but the sign must be taken into account in y to choose the
        # correct diagonal direction.
        floor.inc(Point(
          x: vent.min.x + abs(offset),
          y: vent.min.y + offset
        ))

  return floor

proc solve_first_part*(input: seq[Vent]): int =
  ## Solve the first part by finding the horizontal and vertical overlaps.
  let
    relevant = input.filter_it(it.min.x == it.max.x or it.min.y == it.max.y)
    floor = count_vent_overlaps(relevant)
    overlaps = floor.values().to_seq().filter_it(it > 1).len()

  return overlaps

proc solve_second_part*(input: seq[Vent]): int =
  ## Solve the first part by finding the horizontal, vertical and diagonal
  ## overlaps.
  let
    floor = count_vent_overlaps(input)
    overlaps = floor.values().to_seq().filter_it(it > 1).len()

  return overlaps

proc solve*(path: string) =
  ## Solve the Day 05 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
