# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import aoc21pkg/[day01, day02, day03, day04, day05]

test "day 01 using test input":
  let input = day01.read_input("./assets/test/input_01.txt")
  check day01.solve_first_part(input) == 7
  check day01.solve_second_part(input) == 5

test "day 02 using test input":
  let input = day02.read_input("./assets/test/input_02.txt")
  check day02.solve_first_part(input) == 150
  check day02.solve_second_part(input) == 900

test "day 03 using test input":
  let input = day03.read_input("./assets/test/input_03.txt")
  check day03.solve_first_part(input) == 198
  check day03.solve_second_part(input) == 230

test "day 04 using test input":
  var (numbers, board) = day04.read_input("./assets/test/input_04.txt")
  check day04.solve_first_part(numbers, board) == 4512
  check day04.solve_second_part(numbers, board) == 1924

test "day 05 using test input":
  let input = day05.read_input("./assets/test/input_05.txt")
  check day05.solve_first_part(input) == 5
  check day05.solve_second_part(input) == 12
