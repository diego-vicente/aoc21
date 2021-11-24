import std/parseopt
import std/strutils
import std/strformat

type
  ProblemInput = object
    day*: int
    file*: string


proc write_header*() =
  echo("""
          _      _             _          __         ____
         /_\  __| |_ _____ _ _| |_   ___ / _|     .-" +' "-.
        / _ \/ _` \ V / -_) ' \  _| / _ \  _|    /.'.'A_'*`.\
       /_/ \_\__,_|\_/\___|_||_\__| \___/_|     |:.*'/\-\. ':|
                                                |:.'.||"|.'*:|
         ___         _       ___ __ ___ _        \:~^~^~^~^:/
        / __|___  __| |___  |_  )  \_  ) |        /`-....-'\
       | (__/ _ \/ _` / -_)  / / () / /| |       /          \
        \___\___/\__,_\___| /___\__/___|_|       `-.,____,.-'


Welcome to Diego Vicente's solutions for the Advent of Code 2021! These
solutions are written in Nim and compiled in a single binary. Provide a
day and a number and the execution will be performed below.
""")


proc parse_cli_flags(): ProblemInput =
  ## Parse the CLI arguments into an input object. Only the day (-d, --day) and
  ## the path to input file (-f, --file) are valid flags.
  var
    cli_input = parseopt.initOptParser()
    day: int
    file: string

  while true:
    cli_input.next()
    case cli_input.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case cli_input.key
      of "d", "day":
        day = parse_int(cli_input.val)
      of "f", "file":
        file = cli_input.val
      else:
        raise newException(
          ValueError,
          &"Could not parse the option: {cli_input.key}"
        )
    of cmdArgument:
      raise newException(
        ValueError,
        &"Unexpected argument: {cli_input.key}"
      )

  return ProblemInput(day: day, file: file)


proc get_problem_input*(): ProblemInput =
  ## Load the input to the routine, both by importing the input arguments via
  ## CLI and the prompting the user for all the missing values.
  var input = parse_cli_flags()

  while not input.day in 1..25:
    echo("Please provide a valid day (1-25): ")
    input.day = parse_int(read_line(stdin))

  while input.file == "":
    echo("Please provide the path to an input file: ")
    input.file = read_line(stdin)

  return input
