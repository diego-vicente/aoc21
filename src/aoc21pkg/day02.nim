import std/[sugar, strutils, strformat]


type
  Direction = enum Forward = "forward", Down = "down", Up = "up"
  Action = tuple
    direction: Direction
    amount: int
  SimplePosition = object
    depth: int
    distance: int
  AdvancedPosition = object
    depth: int
    distance: int
    aim: int

proc read_input*(path: string): seq[Action] =
  ## Parse the input file into a sequence of valid Action
  collect(new_seq):
    for line in read_file(path).split("\n"):
      if line != "":
        let parts = line.split(" ")

        if len(parts) != 2:
          raise newException(ValueError, &"Invalid line {line}")

        let direction = parse_enum[Direction](parts[0])
        let amount = parse_int(parts[1])
        (direction, amount)

proc execute_simple_actions(actions: seq[Action]): SimplePosition =
  ## Execute a set of actions as inferred in the problem.
  ##
  ## It returns a simple position, based on depth and distance. Each action can
  ## move forward, modifying the distance; or up and down, modifying the depth
  ## of the submarine.
  var position = SimplePosition(depth: 0, distance: 0)

  for action in actions:
    case action.direction
    of Forward: position.distance += action.amount
    of Down: position.depth += action.amount
    of Up: position.depth -= action.amount

  return position

proc execute_advanced_actions(actions: seq[Action]): AdvancedPosition =
  ## Execute a set of actions as defined in the manual
  ##
  ## It returns an advanced position, based on depth, distance and aim. Each
  ## action can move forward, modifying the distance and depth; or up and down,
  ## modifying the aim of the submarine.
  var position = AdvancedPosition(depth: 0, distance: 0, aim: 0)

  for action in actions:
    case action.direction
    of Forward:
      position.distance += action.amount
      position.depth += position.aim * action.amount
    of Down: position.aim += action.amount
    of Up: position.aim -= action.amount

  return position

proc solve_first_part*(input: seq[Action]): int =
  ## Move the submarine following the actions and return product of the
  ## position.
  let final_position = execute_simple_actions(input)
  return final_position.depth * final_position.distance

proc solve_second_part*(input: seq[Action]): int =
  ## Move the submarine following the manual actions and return product of the
  ## position.
  let final_position = execute_advanced_actions(input)
  return final_position.depth * final_position.distance

proc solve*(path: string) =
  ## Solve the Day 01 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
