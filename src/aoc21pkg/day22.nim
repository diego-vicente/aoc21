import std/[sugar, math, re, sets, sequtils, strutils, strformat, tables]

type
  Instruction = enum Off = "off", On = "on"
  DimRange = tuple
    min_value, max_value: int
  RegularVolume = object
    x, y, z: DimRange
  IrregularVolume = seq[RegularVolume]
  RebootStep = tuple
    instruction: Instruction
    volume: RegularVolume

proc `$`(dim: DimRange): string =
  ## Represent a DimRange in a more terse way.
  &"{dim.min_value}..{dim.max_value}"

proc read_input*(path: string): seq[RebootStep] =
  ## Read the input into a sequence of reboot steps.
  var matches: array[7, string]
  let re = re"(on|off) x=(-?\d*)..(-?\d*),y=(-?\d*)..(-?\d*),z=(-?\d*)..(-?\d*)"

  collect:
    for line in read_file(path).split("\n"):
      if line.match(re, matches):
        let
          instruction = parse_enum[Instruction](matches[0])
          volume = RegularVolume(
            x: (matches[1].parse_int(), matches[2].parse_int()),
            y: (matches[3].parse_int(), matches[4].parse_int()),
            z: (matches[5].parse_int(), matches[6].parse_int())
          )
        (instruction, volume)

proc overlaps(a, b: DimRange): bool =
  ## A DimRange overlaps when there are units in common.
  min(a.max_value, b.max_value) >= max(a.min_value, b.min_value)

proc `in`(a, b: DimRange): bool =
  ## A DimRange is inside another when all units are inside the other one.
  a.min_value >= b.min_value and a.max_value <= b.max_value

proc `notin`(a, b: DimRange): bool =
  ## A DimRange is not inside another when not all units are inside the other
  ## one.
  not (a in b)

proc overlaps(a, b: RegularVolume): bool =
  ## A RegularVolume overlaps another one when all dimensions overlap.
  a.x.overlaps(b.x) and a.y.overlaps(b.y) and a.z.overlaps(b.z)

proc `in`(a, b: RegularVolume): bool =
  ## A RegularVolume is inside another one when all cuboids are inside the other one.
  a.x in b.x and a.y in b.y and a.z in b.z

proc `notin`(a, b: RegularVolume): bool =
  ## A RegularVolume is not inside another one when not all cuboids are inside the other
  ## one.
  not (a in b)

proc `==`(a, b: RegularVolume): bool =
  ## A volume is equal to another one when they cover the same cuboids.
  a.x == b.x and a.y == b.y and a.z == b.z

proc cuboids(volume: RegularVolume): int =
  ## How many cuboids lay within a given RegularVolume.
  let
    x_dim = volume.x.max_value - volume.x.min_value + 1
    y_dim = volume.y.max_value - volume.y.min_value + 1
    z_dim = volume.z.max_value - volume.z.min_value + 1

  return x_dim * y_dim * z_dim

proc cuboids(volume: IrregularVolume): int =
  ## How many cuboids lay within a given IrregularVolume.
  ##
  ## Note: the function assumes that all its splits are not overlapping.
  volume.map_it(it.cuboids()).sum()

proc split(a, b: DimRange): seq[DimRange] =
  ## Get the splits of two DimRanges that overlap.
  ##
  ## When two DimRanges overlap, this function will return the three DimRanges
  ## that will have different properties: one for the intersection of both `a`
  ## and `b` and two for each remainder of `a` and `b` respectively. When they
  ## do not overlap, a sequence of both original DimRanges is returned.
  ##
  ## This function serves as a building block for more complex, N-dimensional
  ## functions.
  if not a.overlaps(b):
    return @[a, b]

  let
    abs_min = min(a.min_value, b.min_value)
    abs_max = max(a.max_value, b.max_value)
    split_min = max(a.min_value, b.min_value)
    split_max = min(a.max_value, b.max_value)

  return @[
    (abs_min, split_min - 1),
    (split_min, split_max),
    (split_max + 1, abs_max)
  ]

proc substract(a, b: RegularVolume): IrregularVolume =
  ## Return the set of volumes that result from removing `b` from `a`.
  ##
  ## When overlapping, this function will return the set of regular volumes
  ## that equal to have all cuboids within `b` removed from `a`.
  if not a.overlaps(b):
    return @[a]

  collect:
    for dim_x in a.x.split(b.x):
      for dim_y in a.y.split(b.y):
        for dim_z in a.z.split(b.z):
          let candidate = RegularVolume(x: dim_x, y: dim_y, z: dim_z)
          if candidate in a and candidate notin b:
            candidate

proc run_reboot_steps(steps: seq[RebootStep]): IrregularVolume =
  ## Run all reboot steps from an empty space.
  ##
  ## The function will accumulate all active regions (turning on or off
  ## depending on each step's definition) and will return the irregular volume
  ## that is one after all steps.
  var region_acc: IrregularVolume = @[]

  for (instruction, step_volume) in steps:
    var step_pieces = region_acc

    for existing in region_acc:
      # If this volume is inside this step's volume, just delete it
      if existing in step_volume:
        step_pieces.delete(step_pieces.find(existing))

      # If it just overlaps, delete the original volume but include the pieces
      # of the original volume that do not overlap
      elif existing.overlaps(step_volume):
        step_pieces.delete(step_pieces.find(existing))
        let splits = existing.substract(step_volume)
        step_pieces = step_pieces & splits

    # If the step turns the volume on, just add the volume. After computing the
    # splits, there will be no overlapping pieces.
    case instruction
    of On: region_acc = step_pieces & @[step_volume]
    # If the step turns the volume off, simply include the new pieces and omit
    # the volume.
    of Off: region_acc = step_pieces

  return region_acc

proc solve_first_part*(input: seq[RebootStep]): int =
  ## To solve the first part, run the initialization steps.
  let
    initialization = RegularVolume(x: (-50, 50), y: (-50, 50), z: (-50, 50))
    relevant = input.filter_it(it.volume in initialization)
    region = run_reboot_steps(relevant)
  return region.cuboids()

proc solve_second_part*(input: seq[RebootStep]): int =
  ## To solve the second part, run all the reboot steps.
  let region = run_reboot_steps(input)
  return region.cuboids()

proc solve*(path: string) =
  ## Solve the Day 22 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
