import std/[math, strutils, strformat, sequtils, tables]


proc read_input*(path: string): seq[int] =
  ## Parse the input file into a sequence of timers.
  read_file(path).split(",").map_it(it.strip().parse_int())

proc to_population(input: seq[int]): CountTable[int] =
  ## Count how many of each timers are.
  to_count_table(input)

proc next_generation(original: var CountTable[int]): CountTable[int] =
  ## Compute the next generation of a population.
  var
    next = init_count_table[int]()
    due_today = original[0]

  # The ones due to day reset to 6 and spawn one 8 each
  next[8] = due_today
  next[6] = due_today

  # The rest of them decrease the days left by one
  for (days, population) in original.mpairs():
    if days > 0:
      next[days - 1] = next[days - 1] + population

  return next

proc simulate(population: CountTable[int], generations: int): CountTable[int] =
  ## Run several generations for the population.
  var population = population

  for day in 0..<generations:
    population = population.next_generation()

  return population

proc solve_first_part*(input: seq[int]): int =
  ## Compute the number of lanterfishes after 80 days.
  var population = input.to_population.simulate(80)
  return population.values.to_seq.sum()

proc solve_second_part*(input: seq[int]): int =
  ## Compute the number of lanterfishes after 256 days.
  var population = input.to_population.simulate(256)
  return population.values.to_seq.sum()

proc solve*(path: string) =
  ## Solve the Day 06 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
