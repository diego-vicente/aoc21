import std/[sugar, math, strformat, strutils, sequtils, options]

import fusion/matching

{.experimental: "caseStmtMacros".}

type
  Board = object
    numbers: array[0..25, int]
    seen: array[0..25, bool]
    drawn: seq[int]

proc read_board(raw: string): Board =
  ## Parse a set of numbers into a Board object.
  var numbers: array[0..25, int]
  let elements = raw.split_whitespace()

  assert len(elements) == 25
  for i, number in elements:
    numbers[i] = parse_int(number)

  return Board(numbers: numbers)

proc read_input*(path: string): (seq[int], seq[Board]) =
  ## Parse the input file into a complete bingo game.
  let
    elements = read_file(path).split("\n\n")
    numbers = elements[0].split(",").map_it(parse_int(it))
    boards = elements[1..elements.high].map_it(read_board(it))

  return (numbers, boards)

proc is_winner(board: Board): bool =
  ## Return if this board has won already or not.
  # Check if any row is the winner
  for row in 0 ..< 5:
    let relevant = collect(new_seq):
      for i, seen in board.seen:
        if i div 5 == row:
          seen

    if all(relevant, proc (b: bool): bool = b):
      return true

  # Check if any column is the winner
  for col in 0 ..< 5:
    let relevant = collect(new_seq):
      for i, seen in board.seen:
        if i mod 5 == col:
          seen

    if all(relevant, proc (b: bool): bool = b):
      return true

  return false

proc compute_score(board: Board, drawn: int): int =
  ## Compute the score as per the problem statement.
  let not_drawn = collect(new_seq):
    for i, seen in board.seen:
      if not seen: board.numbers[i]

  return drawn * sum(not_drawn)

proc mark_number(board: var Board, drawn: int): Option[int] =
  ## Mark a number as already drawn.
  ##
  ## Returns the score of the game if it just won, or none otherwise.
  for i, number in board.numbers:
    if number == drawn:
      board.seen[i] = true
      if board.is_winner():
        let score = board.compute_score(drawn)
        return some(score)
  return none(int)

proc solve_first_part*(numbers: seq[int], boards: var seq[Board]): int =
  ## Solve the first part by finding the score of the winner board.
  for number in numbers:
    for board in boards.mitems():
      case board.mark_number(number)
      of Some(@score): return score
      of None(int): continue

  return 0

proc solve_second_part*(numbers: seq[int], boards: var seq[Board]): int =
  ## Solve the first part by finding the score of the last board to win.
  var
    already_won = new_seq[bool](len(boards))
    boards_left = len(boards)

  for number in numbers:
    for i, board in boards.mpairs():
      if not already_won[i]:
        case board.mark_number(number)
        of None(int): continue
        of Some(@score):
          already_won[i] = true
          dec boards_left
          if boards_left == 0:
            return score

  return 0

proc solve*(path: string) =
  ## Solve the Day 03 problem and output
  var (numbers, boards) = read_input(path)
  let solution_1 = solve_first_part(numbers, boards)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(numbers, boards)
  echo(&"Solution to the second part: {solution_2}")
