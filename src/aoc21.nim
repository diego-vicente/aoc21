# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import std/parseopt
import std/strutils
import std/strformat

import aoc21pkg/cli
import aoc21pkg/[day01, day02, day03, day04, day05, day06, day07, day08, day09]

when isMainModule:
  cli.write_header()
  let input = cli.get_problem_input()
  echo(&"Launching day {input.day} with {input.file}")

  case input.day
  of 1: day01.solve(input.file)
  of 2: day02.solve(input.file)
  of 3: day03.solve(input.file)
  of 4: day04.solve(input.file)
  of 5: day05.solve(input.file)
  of 6: day06.solve(input.file)
  of 7: day07.solve(input.file)
  of 8: day08.solve(input.file)
  of 9: day09.solve(input.file)
  else: echo(&"Day {input.day} has not yet been implemented")
