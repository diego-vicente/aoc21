import std/[sugar, strutils, strformat, sequtils]

type
  Bit = char
  BinInt = string


proc read_input*(path: string): seq[BinInt] =
  ## Parse the input file into a sequence of BinInt
  collect(new_seq):
    for line in read_file(path).split("\n"):
      if line != "": line

proc complement(bit: Bit): Bit =
  ## Return the complement of a given bit.
  if bit == '1':
    return '0'
  if bit == '0':
    return '1'

proc most_common_bit_at(nums: seq[BinInt], position: int = 0): Bit =
  ## Return the most common Bit in a given position in some binary numbers.
  ##
  ## If there are the same number of 1s and 0s, the function returns 1. This is
  ## in order to comply with the given statement.
  var
    n_ones = 0
  for num in nums:
    if num[position] == '1':
      inc n_ones

  if n_ones >= len(nums) - n_ones:
    return '1'
  else:
    return '0'

proc compute_gamma_rate(input: seq[BinInt]): BinInt =
  ## Compute the gamma rate out of a set of binary numbers.
  var
    gamma: BinInt = ""

  for position in 0..input[0].high:
    gamma.add(input.most_common_bit_at(position))

  return gamma

proc infer_epsilon_rate(gamma: BinInt): BinInt =
  ## Infer the epsilon rate as the complemet of a gamma rate.
  var epsilon: BinInt = ""

  for bit in gamma:
    epsilon.add(complement(bit))

  return epsilon

proc compute_oxygen_gen_rating(input: seq[BinInt]): BinInt =
  ## Compute the oxygen generator rating of a set of numbers.
  var
    candidates = input

  for position in 0..input[0].high:
    if len(candidates) == 1:
      break

    let common = candidates.most_common_bit_at(position)
    candidates = candidates.filterIt(it[position] == common)

  return candidates[0]

proc compute_co2_scrubber_rating(input: seq[BinInt]): BinInt =
  ## Compute the CO2 scrubber rating of a set of numbers.
  var
    candidates = input

  for position in 0..input[0].high:
    if len(candidates) == 1:
      break

    let common = candidates.most_common_bit_at(position)
    candidates = candidates.filterIt(it[position] == complement(common))

  return candidates[0]

proc solve_first_part*(input: seq[BinInt]): int =
  ## Solve the first part by finding the product of epsilon and gamma.
  let gamma = compute_gamma_rate(input)
  let epsilon = infer_epsilon_rate(gamma)
  return parse_bin_int(gamma) * parse_bin_int(epsilon)

proc solve_second_part*(input: seq[BinInt]): int =
  ## Solve the second part by finding the product of O2 and CO2 ratings.
  let oxygen = compute_oxygen_gen_rating(input)
  let co2 = compute_co2_scrubber_rating(input)
  return parse_bin_int(oxygen) * parse_bin_int(co2)

proc solve*(path: string) =
  ## Solve the Day 03 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
