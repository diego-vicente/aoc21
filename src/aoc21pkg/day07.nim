import std/[sugar, algorithm, math, stats, strutils, strformat, sequtils]


proc read_input*(path: string): seq[int] =
  ## Parse the input file into a sequence of positions.
  read_file(path).split(",").map_it(it.strip().parse_int())

proc median(xs: seq[int]): int =
  ## Compute the median of the sequence.
  xs.sorted()[xs.len div 2]

proc compute_distance(positions: seq[int], target: int): int =
  ## Compute the total distance of all crabs to the target.
  positions.map_it(abs(it - target)).sum()

proc compute_fuel(positions: seq[int], target: int): int =
  ## Compute the total fuel consumption of all crabs to the target.
  ##
  ## Since the second parts aggregates the fuel increasing each unit by one, it
  ## is equivalent to computing the sum of all numbers from 1 to the total
  ## distance. To do so, the Gauss Theorem is used in this function.
  let fuels = collect(new_seq):
    for position in positions:
      let
        distance = abs(position - target)
        fuel = distance * (distance + 1) / 2
      fuel.int()

  return fuels.sum()

proc solve_first_part*(input: seq[int]): int =
  ## Compute the first part using the median of the positions.
  let
    target = median(input)
    fuel = compute_distance(input, target)

  return fuel

proc solve_second_part*(input: seq[int]): int =
  ## Compute the second part using the mean of the positions.
  let
    target = mean(input).int()
    fuel = compute_fuel(input, target)

  return fuel

proc solve*(path: string) =
  ## Solve the Day 07 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
