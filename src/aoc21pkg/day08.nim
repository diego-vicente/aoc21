import std/[sugar, algorithm, math, sets, strutils, strformat, sequtils, tables]


type
  DisplayOutput = HashSet[char]
  WireSegmentConn = Table[DisplayOutput, char]
  OutputSequence = object
    reference: seq[string]
    output: seq[string]


proc to_display_output(raw: string): DisplayOutput =
  raw.items.to_seq.to_hash_set()

proc read_input*(path: string): seq[OutputSequence] =
  ## Parse the input file into a sequence of display tests.
  collect(new_seq):
    for line in read_file(path).split("\n"):
      if line != "":
        let parts = line.split(" | ")
        OutputSequence(
          reference: parts[0].split().to_seq(),
          output: parts[1].split().to_seq()
        )

proc create_new_mapping(output: OutputSequence): WireSegmentConn =
  ## Out of a display test, infer a wire connection out of it.
  var conn = init_table[DisplayOutput, char]()

  let
    reference = output.reference.map_it(it.to_display_output())
    # These are the basic ones - filtered by length
    one = reference.filter_it(it.len == 2)[0]
    four = reference.filter_it(it.len == 4)[0]
    seven = reference.filter_it(it.len == 3)[0]
    eight = reference.filter_it(it.len == 7)[0]
    # These are the ones inferred by elimination
    nine = reference.filter_it(
      it.len == 6 and (four - it).len == 0
    )[0]
    zero = reference.filter_it(
      it.len == 6 and (one - it).len == 0 and it != nine
    )[0]
    six = reference.filter_it(
      it.len == 6 and it != nine and it != zero
    )[0]
    three = reference.filter_it(
      it.len == 5 and (one - it).len == 0
    )[0]
    two = reference.filter_it(
      it.len == 5 and (four + it) == eight
    )[0]
    five = reference.filter_it(
      it.len == 5 and it != two and it != three
    )[0]

  # Include the mapping in the object
  conn[zero] = '0'
  conn[one] = '1'
  conn[two] = '2'
  conn[three] = '3'
  conn[four] = '4'
  conn[five] = '5'
  conn[six] = '6'
  conn[seven] = '7'
  conn[eight] = '8'
  conn[nine] = '9'

  return conn

proc decode_output(conn: WireSegmentConn, output: OutputSequence): int =
  ## Use a wire connection to decode a broken display output.
  var num_str = ""
  for encoded_num in output.output:
    num_str.add(conn[encoded_num.to_display_output])

  return parse_int(num_str)

proc solve_first_part*(input: seq[OutputSequence]): int =
  ## Simply count objects of some length.
  input.map_it(it.output.filter_it(it.len < 5 or it.len > 6).len).sum()

proc solve_second_part*(input: seq[OutputSequence]): int =
  ## Decode the output and sum all instances.
  let decoded_out = collect(new_seq):
    for output in input:
      let conn = create_new_mapping(output)
      conn.decode_output(output)

  return sum(decoded_out)

proc solve*(path: string) =
  ## Solve the Day 08 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
