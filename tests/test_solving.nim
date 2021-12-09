# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import aoc21pkg/[day01, day02, day03, day04, day05, day06, day07]

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

test "day 06 using test input":
  let input = day06.read_input("./assets/test/input_06.txt")
  check day06.solve_first_part(input) == 5934
  check day06.solve_second_part(input) == 26984457539

test "day 07 using test input":
  let input = day07.read_input("./assets/test/input_07.txt")
  check day07.solve_first_part(input) == 37
  check day07.solve_second_part(input) == 170
