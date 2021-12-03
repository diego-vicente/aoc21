# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import aoc21pkg/[day01, day02]

test "day 01 using test input":
  let input = day01.read_input("./assets/test/input_01.txt")
  check day01.solve_first_part(input) == 7
  check day01.solve_second_part(input) == 5

test "day 02 using test input":
  let input = day02.read_input("./assets/test/input_02.txt")
  check day02.solve_first_part(input) == 150
  check day02.solve_second_part(input) == 900
