import std/[sugar, enumerate, sets, sequtils, strutils, strformat, tables]

type
  Point = tuple
    x, y: int
  Algorithm = seq[bool]
  Image = object
    points: HashSet[Point]
    min_x, min_y, max_x, max_y: int
    default: bool

proc parse_enhancement(raw: string): Algorithm =
  ## Parse a raw text input into a valid enhancement algorithm.
  collect:
    for pixel in raw:
      pixel == '#'

proc to_image(points: HashSet[Point], default: bool): Image =
  ## Generate a valid Image by inferring the bounds of a set of points.
  let
    ys = points.map_it(it.y).to_seq()
    xs = points.map_it(it.x).to_seq()

  return Image(
    points: points,
    min_x: xs.min(),
    min_y: ys.min(),
    max_x: xs.max(),
    max_y: ys.max(),
    default: default
  )

proc parse_image(raw: string): Image =
  ## Parse an image out of raw text input.
  let points = collect:
    for y, line in raw.split("\n").pairs():
      for x, pixel in line.pairs():
        if pixel == '#': {(x, y)}

  return to_image(points, false)

proc read_input*(path: string): (Algorithm, Image) =
  ## Parse the input file into an enhancement algorithm and an input image.
  let
    parts = read_file(path).split("\n\n")
    enhancement = parse_enhancement(parts[0])
    image = parse_image(parts[1])

  return (enhancement, image)

proc `[]`(image: Image, p: Point): bool =
  ## Return the value of a pixel in an image.
  ##
  ## A pixel is defined by its (x, y) coordinates and it's checked to be lit
  ## only if it lays within bounds. Since some enhancement algorithms cause the
  ## image to flash (alternating all bounds to be lit or not each step) a
  ## default value is hosted in an image to return it when accessing out of
  ## bounds values.
  if p.x in image.min_x..image.max_x and p.y in image.min_y..image.max_y:
    return p in image.points
  else:
    return image.default

proc get_neighbor_index(image: Image, point: Point): int =
  ## Return the index inferred from a point's neighborhood
  var bin_idx = ""

  for dy in [-1, 0, 1]:
    for dx in [-1, 0, 1]:
      let value = image[(point.x + dx, point.y + dy)]
      if value:
        bin_idx.add("1")
      else:
        bin_idx.add("0")

  return bin_idx.parse_bin_int()

proc enhance(original: Image, algorithm: Algorithm): Image =
  ## Apply the enhance algorithm to an image.
  ##
  ## Apart from the neighborhood substitution, this function also checks for
  ## flashing algorithms (those in which the infinite boundaries will alternate
  ## between lit and not each step) to initialize the enhanced image to a
  ## sensible default values. These values are used when accessing out of the
  ## significant image boundaries.
  var enhanced: HashSet[Point]

  for y in (original.min_y-1)..(original.max_y+1):
    for x in (original.min_x-1)..(original.max_x+1):
      let
        point = (x, y)
        index = original.get_neighbor_index(point)
        light = algorithm[index]

      if light:
        enhanced.incl(point)

  return Image(
    points: enhanced,
    min_x: original.min_x - 1,
    min_y: original.min_y - 1,
    max_x: original.max_x + 1,
    max_y: original.max_y + 1,
    default: algorithm[0] and not original.default,
  )

proc solve_first_part*(input: Image, algorithm: Algorithm): int =
  ## Return the lit pixels after to enhancement steps.
  input.enhance(algorithm).enhance(algorithm).points.len()

proc solve_second_part*(input: Image, algorithm: Algorithm): int =
  ## Return the lit pixels after 50 iterations.
  var image = input

  for step in 1..50:
    image = image.enhance(algorithm)

  return image.points.len()

proc solve*(path: string) =
  ## Solve the Day 20 problem and output
  let (algorithm, image) = read_input(path)
  let solution_1 = solve_first_part(image, algorithm)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(image, algorithm)
  echo(&"Solution to the second part: {solution_2}")
