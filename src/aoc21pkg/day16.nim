import std/[math, strutils, strformat, sequtils]

type
  Packet = ref object of RootObj
    version: int
    ptype: int

  Literal = ref object of Packet
    lit_value: int

  Operator = ref object of Packet
    length_type_id: int
    length: int
    contents: seq[Packet]

proc read_input*(path: string): string =
  ## Parse the input file into a binary string.
  var number = ""

  # GOTCHA: iterate converting each character to prevent the numeric type
  # overflowing - most inputs are too large to fit in int64
  for hex in read_file(path).strip():
    number = number & from_hex[int]($hex).to_bin(4)

  return number

# Define the method to allow for mutual recursion during parsing
proc parse(input: var string): Packet

proc parse_contents(packet: var Literal, input: var string) =
  ## Parse input into a literal packet's value.
  var
    accumulator = ""
    parsing_done = false

  while not parsing_done:
    let
      flag = input[0]
      lit_value = input[1..4]

    accumulator = accumulator & lit_value
    input = input[5..input.high]
    parsing_done = flag == '0'

  packet.lit_value = from_bin[int](accumulator)

proc infer_contents_length(packet: var Operator, input: var string) =
  ## Infer the length of the input that belongs to an Operator packet.
  let length_type_id = from_bin[int]($input[0])

  var length: int

  if length_type_id == 0:
    length = from_bin[int](input[1..15])
    input = input[16..input.high]
  elif length_type_id == 1:
    length = from_bin[int](input[1..11])
    input = input[12..input.high]

  packet.length_type_id = length_type_id
  packet.length = length

proc parse_contents(packet: var Operator, input: var string) =
  ## Parse the input into the contents of an Operator packet.
  if packet.length_type_id == 0:
    var contents = input[0..packet.length - 1]

    # Parse the contents until there is nothing but padding left.
    while not contents.all(proc (b: char): bool = b == '0'):
      packet.contents.add(contents.parse())

    # Consume the input after parsing the given length
    input = input[packet.length..input.high]

  elif packet.length_type_id == 1:
    while packet.contents.len < packet.length:
      packet.contents.add(input.parse())

proc parse(input: var string): Packet =
  ## Parse the binary input into a given packet.
  ## Take into account that this method is destructive and consumes the given input.
  let
    version = from_bin[int](input[0..2])
    ptype = from_bin[int](input[3..5])

  # Consume the header
  input = input[6..input.high]

  if ptype == 4:
    var packet = Literal(version: version, ptype: ptype)
    packet.parse_contents(input)
    return packet

  else:
    var packet = Operator(version: version, ptype: ptype)
    packet.infer_contents_length(input)
    packet.parse_contents(input)
    return packet

method sum_versions(packet: Packet): int {.base.} =
  ## Return the sum of this packet version and all contents related.
  raise newException(CatchableError, "Method without implementation override")

method sum_versions(packet: Literal): int =
  ## The version associated with a Literal is its version
  packet.version

method sum_versions(packet: Operator): int =
  ## The version associated with an Operator is its version and all of its
  ## contents.
  packet.version + packet.contents.map_it(it.sum_versions()).sum()

method value(packet: Packet): int {.base.} =
  ## The value associated with a packet is the result of its operation.
  raise newException(CatchableError, "Method without implementation override")

method value(packet: Literal): int =
  ## The value associated with a Literal is its value.
  packet.lit_value

method value(packet: Operator): int =
  ## The value associated with an Operator is the result of its operation.
  case packet.ptype
  of 0: packet.contents.map_it(it.value).sum()
  of 1: packet.contents.map_it(it.value).prod()
  of 2: packet.contents.map_it(it.value).min()
  of 3: packet.contents.map_it(it.value).max()
  of 5: (packet.contents[0].value > packet.contents[1].value).int()
  of 6: (packet.contents[0].value < packet.contents[1].value).int()
  of 7: (packet.contents[0].value == packet.contents[1].value).int()
  else: raise newException(ValueError, "wrong operator type")

proc solve_first_part*(input: string): int =
  ## Return the sum of versions in the input.
  var
    consumable = input
    packet = consumable.parse()
  return packet.sum_versions()

proc solve_second_part*(input: string): int =
  ## Return the result of the operations in the input.
  var
    consumable = input
    packet = consumable.parse()
  return packet.value

proc solve*(path: string) =
  ## Solve the Day 16 problem and output
  var input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
