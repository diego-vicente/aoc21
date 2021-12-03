import std/[sugar, strutils, strformat]


type
  SonarReading = seq[int]
  Increments = seq[(int, int)]

proc read_input*(path: string): SonarReading =
  ## Parse the input file into a sequence of valid readings
  collect(new_seq):
    for line in read_file(path).split("\n"):
      if line != "":
        parse_int(line)

proc filter_increments(input: SonarReading, offset: int = 1): Increments =
  ## Filter all increments taking into account any possible offset.
  ##
  ## To reduce noise, we are eventually asked to compare the sum of the rolling
  ## windows, but this is not strictly necessary since the difference is only
  ## marked by the first and last elements of the comparison. Following the
  ## statements info:
  ##
  ## ```
  ## 199  A
  ## 200  A B
  ## 208  A B
  ## 210    B
  ## ```
  ##
  ## Comparing the sum of A to the sum of B is equivalent to comparing A[0] =
  ## 199 to B[2] = 210, since 200 and 208 are a common intersection to both
  ## sums.
  collect(new_seq):
    for i, reading in input.pairs:
      if i >= offset:
        if reading > input[i - offset]:
          (i, reading)

proc solve_first_part*(input: SonarReading): int =
  ## Count all the simple increments in the input.
  let increments = filter_increments(input)
  return len(increments)

proc solve_second_part*(input: SonarReading): int =
  ## Count all the increments in rolling windows of length 3.
  let increments = filter_increments(input, offset = 3)
  return len(increments)

proc solve*(path: string) =
  ## Solve the Day 01 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
