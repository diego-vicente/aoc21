import std/[sugar, algorithm, deques, math, strutils, strformat]

type
  TokenType = enum Parenthesis, SquareBracket, CurlyBracket, AngleBracket
  CheckStatus = enum Correct, Expected, Unexpected, Invalid
  CheckResult = tuple
    status: CheckStatus
    info: string
  SyntaxStack = Deque[TokenType]

proc read_input*(path: string): seq[string] =
  ## Parse the input file into a list of strings.
  collect(new_seq):
    for line in read_file(path).split("\n"):
      if line != "":
        line

proc remaining_sequence(syntax_stack: SyntaxStack): string =
  ## Get the minimal sequence needed to complete correctly a syntax stack.
  var sequence = ""

  for token in syntax_stack:
    case token
    of Parenthesis: sequence.add(")")
    of SquareBracket: sequence.add("]")
    of CurlyBracket: sequence.add("}")
    of AngleBracket: sequence.add(">")

  return sequence

proc check_balance(chunk: string): CheckResult =
  ## Perform a balance check for a given chunk.
  ##
  ## The function returns both the status of the check and the relevant info if
  ## needed, which may be the unexpected token or the missing sequence in case
  ## the chunk is incomplete.
  var syntax_stack = init_deque[TokenType]()

  for token in chunk.items():
    case token
    of '(': syntax_stack.add_first(Parenthesis)
    of '[': syntax_stack.add_first(SquareBracket)
    of '{': syntax_stack.add_first(CurlyBracket)
    of '<': syntax_stack.add_first(AngleBracket)
    of ')':
      if syntax_stack.len == 0 or syntax_stack.pop_first() != Parenthesis:
        return (Unexpected, ")")
    of ']':
      if syntax_stack.len == 0 or syntax_stack.pop_first() != SquareBracket:
        return (Unexpected, "]")
    of '}':
      if syntax_stack.len == 0 or syntax_stack.pop_first() != CurlyBracket:
        return (Unexpected, "}")
    of '>':
      if syntax_stack.len == 0 or syntax_stack.pop_first() != AngleBracket:
        return (Unexpected, ">")
    else: return (Invalid, "")

  if syntax_stack.len > 0:
    return (Expected, syntax_stack.remaining_sequence())
  else:
    return (Correct, "")

proc solve_first_part*(input: seq[string]): int =
  ## Solve the first part counting the corrupted sequences score.
  let scores = collect(new_seq):
    for chunk in input:
      let (status, info) = chunk.check_balance()
      if status == Unexpected:
        case info
        of ")": 3
        of "]": 57
        of "}": 1197
        of ">": 25137
        else: 0

  return scores.sum()

proc solve_second_part*(input: seq[string]): int =
  ## Solve the first part counting the incomplete sequences score.
  let scores = collect(new_seq):
    for chunk in input:
      let (status, info) = chunk.check_balance()
      if status == Expected:
        var
          score = 0
          token_score = 0

        for token in info:
          case token
          of ')': token_score = 1
          of ']': token_score = 2
          of '}': token_score = 3
          of '>': token_score = 4
          else: token_score = 0
          score = score * 5 + token_score

        score

  return scores.sorted()[scores.len div 2]

proc solve*(path: string) =
  ## Solve the Day 10 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
