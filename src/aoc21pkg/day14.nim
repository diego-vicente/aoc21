import std/[sugar, strutils, strformat, sequtils, tables]

type
  Polymer = char
  PolymerPair = (Polymer, Polymer)
  Template = seq[Polymer]
  InsertionRules = Table[PolymerPair, Polymer]
  Frequencies = object
    polymer: CountTable[Polymer]
    pair: CountTable[PolymerPair]

proc read_input*(path: string): (Template, InsertionRules) =
  ## Parse the input file into a set of instructions (points and folds).
  let
    parts = read_file(path).split("\n\n")
    initial = parts[0].to_seq()
    rules = collect:
      for line in parts[1].split("\n"):
        if line != "":
          let
            sides = line.split(" -> ")
            lhs = (sides[0][0], sides[0][1])
            rhs = sides[1][0]
          {lhs: rhs}

  return (initial, rules)

proc to_pair_count_table(initial: Template): CountTable[PolymerPair] =
  ## Count the pairs of polymers appearing in a given template.
  var table = init_count_table[PolymerPair]()

  for i in 1..initial.high:
    let
      a = initial[i - 1]
      b = initial[i]

    table.inc((a, b))

  return table

proc to_frequencies(initial: Template): Frequencies =
  ## Out of a initial template, return the frequencies.
  var
    polymer = initial.to_count_table()
    pair = initial.to_pair_count_table()

  Frequencies(polymer: polymer, pair: pair)

proc perform_step(previous: var Frequencies, rules: InsertionRules) =
  ## Perform all the expansions and update the frequencies in place.
  var next = Frequencies(
    polymer: previous.polymer,
    pair: init_count_table[PolymerPair]()
  )

  for (to_expand, to_insert) in rules.pairs:
    if to_expand notin previous.pair:
      continue

    let
      left_pair = (to_expand[0], to_insert)
      right_pair = (to_insert, to_expand[1])
      count = previous.pair[to_expand]

    next.pair.inc(left_pair, count)
    next.pair.inc(right_pair, count)
    next.polymer.inc(to_insert, count)

  previous = next

proc solve_first_part*(initial: Template, rules: InsertionRules): int =
  ## Perform 10 steps and return the desired count.
  var frequencies = initial.to_frequencies()

  for i in 1..10:
    frequencies.perform_step(rules)

  let
    most_common = frequencies.polymer.values.to_seq.max()
    least_common = frequencies.polymer.values.to_seq.min()

  return most_common - least_common

proc solve_second_part*(initial: Template, rules: InsertionRules): int =
  ## Perform 40 steps and return the desired count.
  var frequencies = initial.to_frequencies()

  for i in 1..40:
    frequencies.perform_step(rules)

  let
    most_common = frequencies.polymer.values.to_seq.max()
    least_common = frequencies.polymer.values.to_seq.min()

  return most_common - least_common

proc solve*(path: string) =
  ## Solve the Day 14 problem and output
  var (initial, rules) = read_input(path)
  let solution_1 = solve_first_part(initial, rules)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(initial, rules)
  echo(&"Solution to the second part: {solution_2}")
