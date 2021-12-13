import std/[sugar, strutils, strformat, sequtils, sets, tables]

type
  Point = tuple
    x: int
    y: int
  Fold = tuple
    axis: char
    at: int
  Instructions = tuple
    points: HashSet[Point]
    folds: seq[Fold]

proc read_input*(path: string): Instructions =
  ## Parse the input file into a set of instructions (points and folds).
  let
    parts = read_file(path).split("\n\n")
    points = collect:
      for line in parts[0].split("\n"):
        if line != "":
          let coords = line.split(",")
          {(coords[0].parse_int(), coords[1].parse_int())}
    folds = collect:
      for line in parts[1].split("\n"):
        if line != "":
          let fold = line.split(" ")[^1].split("=")
          (fold[0][0], fold[1].parse_int())

  return (points, folds)

proc fold(before: HashSet[Point], fold: Fold): HashSet[Point] =
  ## Fold a set of points following the instructions.
  ##
  ## A fold is indicated by its axis and where it is performed. This function
  ## is able to handle X and Y folds and returns the set of points that are
  ## activated afterwards (collisions are automatically handled by the HashSet
  ## class).
  var after = init_hash_set[Point]()

  case fold.axis
  of 'x':
    for point in before:
      if point.x < fold.at:
        after.incl(point)
      elif point.x > fold.at:
        let offset = point.x - fold.at
        after.incl((point.x - offset * 2, point.y))
  of 'y':
    for point in before:
      if point.y < fold.at:
        after.incl(point)
      elif point.y > fold.at:
        let offset = point.y - fold.at
        after.incl((point.x, point.y - offset * 2))
  else:
    raise newException(ValueError, "unknown fold axis")

  return after

proc display(points: HashSet[Point]) =
  ## Display a set of points in the screen.
  let
    max_x = points.to_seq().map_it(it[0]).max()
    max_y = points.to_seq().map_it(it[1]).max()

  for y in 0..max_y:
    var line = ""
    for x in 0..max_x:
      if (x, y) in points:
        line = line & ("\u2588")
      else:
        line = line & (" ")
    echo(line)
  echo()

proc solve_first_part*(input: Instructions): int =
  ## Count activated points after the first fold.
  var (points, folds) = input
  points = points.fold(folds[0])
  return len(points)

proc solve_second_part*(input: Instructions) =
  ## Display the final set of points.
  ##
  ## This part returns no value; instead it displays the points in human
  ## readable grid (but quite hard to parse automatically).
  var (points, folds) = input
  for fold in folds:
    points = points.fold(fold)

  points.display()

proc solve*(path: string) =
  ## Solve the Day 13 problem and output
  var input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  echo("Solution to the second part:")
  solve_second_part(input)
