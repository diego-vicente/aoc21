import std/[sugar, re, sets, sequtils, strutils, strformat, tables]

type
  Position = int
  Player = object
    id: int
    position: Position
    score: int
  Roll = (int, int, int)
  PossibleWins = CountTable[int]
  GameState = tuple
    players: seq[Player]
    turn: int
  ScenarioRecord = Table[GameState, PossibleWins]

proc read_input*(path: string): seq[Player] =
  ## Parse the input file into an enhancement algorithm and an input image.
  let re = re"Player (\d*) starting position: (\d*)"
  var matches: array[2, string]

  collect:
    for line in read_file(path).split("\n"):
      if line.match(re, matches):
        Player(id: matches[0].parse_int(), position: matches[1].parse_int())

iterator deterministic_dice(): Roll =
  ## Returns consecutive numbers from 1 to 100 and wraps around.
  var
    roll_1 = 1
    roll_2 = 2
    roll_3 = 3

  while true:
    yield (roll_1, roll_2, roll_3)
    roll_1 = ((roll_1 + 2) mod 100) + 1
    roll_2 = ((roll_2 + 2) mod 100) + 1
    roll_3 = ((roll_3 + 2) mod 100) + 1

proc advance(player: var Player, rolls: Roll) =
  ## Advance a player using a certain roll.
  let roll = rolls[0] + rolls[1] + rolls[2]
  player.position = ((player.position - 1 + roll) mod 10) + 1
  player.score = player.score + player.position

proc deterministic_game(input: seq[Player]): int =
  ## Run a deterministic game, up to 1000 points.
  var
    players = input
    n_rolls, player_turn: int
    current_player: Player

  for rolls in deterministic_dice():
    player_turn = n_rolls mod input.len
    n_rolls.inc(3)

    players[player_turn].advance(rolls)

    if players[player_turn].score >= 1000:
      break

  let losing_score = players.map_it(it.score).min()
  return losing_score * n_rolls

proc solve_first_part*(input: seq[Player]): int =
  ## The first part is just running a deterministic game.
  deterministic_game(input)

iterator dirac_die(faces: int = 3): Roll =
  ## A Dirac die runs all possible combinations.
  for roll_1 in 1..faces:
    for roll_2 in 1..faces:
      for roll_3 in 1..faces:
        yield (roll_1, roll_2, roll_3)

proc count_victories(players: seq[Player],
                     n_rolls: int,
                     known: var ScenarioRecord
                    ): PossibleWins =
  ## Of all possible combinations, return the wins of each player.
  ##
  ## This function uses memoization in the `known` variable to prevent
  ## redundant computations. It will return a table of each player's id and the
  ## number of universes in which they have won.
  var
    player_turn = n_rolls mod players.len
    state = (players, player_turn)

  # If we have already visited this state, return the known value
  if state in known:
    return known[state]

  # If not, we have yet to check all possibilities
  var victories_below = init_count_table[int]()

  for possibility in dirac_die():
    var instance = players

    instance[player_turn].advance(possibility)

    var instance_victories: PossibleWins

    # If the player has won, there are no universes branching
    if instance[player_turn].score >= 21:
      instance_victories = @[instance[player_turn].id].to_count_table()
    # If not, run the function recursively down the tree
    else:
      instance_victories = count_victories(instance, n_rolls + 3, known)

    # Aggregate the possibilities in a single counter
    victories_below.merge(instance_victories)

  # Update the memoization table and return the value
  known[state] = victories_below
  return victories_below

proc quantum_game(players: seq[Player]): int =
  ## Run a quantum game using the Dirac die.
  var
    known = init_table[GameState, PossibleWins]()
    possibilities = count_victories(players, 0, known)
  return possibilities.values.to_seq.max()

proc solve_second_part*(input: seq[Player]): int =
  ## The second part runs a quantum game.
  quantum_game(input)

proc solve*(path: string) =
  ## Solve the Day 21 problem and output
  let input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
