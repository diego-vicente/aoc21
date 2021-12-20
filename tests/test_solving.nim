# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import aoc21pkg/[
  day01, day02, day03, day04, day05, day06, day07, day08, day09, day10,
  day11, day12, day13, day14, day15, day16, day17, day20
]

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

test "day 08 using test input":
  let input = day08.read_input("./assets/test/input_08.txt")
  check day08.solve_first_part(input) == 26
  check day08.solve_second_part(input) == 61229

test "day 09 using test input":
  let input = day09.read_input("./assets/test/input_09.txt")
  check day09.solve_first_part(input) == 15
  check day09.solve_second_part(input) == 1134

test "day 10 using test input":
  let input = day10.read_input("./assets/test/input_10.txt")
  check day10.solve_first_part(input) == 26397
  check day10.solve_second_part(input) == 288957

test "day 11 using test input":
  let input = day11.read_input("./assets/test/input_11.txt")
  check day11.solve_first_part(input) == 1656
  check day11.solve_second_part(input) == 195

test "day 12 using test input":
  let input = day12.read_input("./assets/test/input_12.txt")
  check day12.solve_first_part(input) == 10
  check day12.solve_second_part(input) == 36

test "day 13 using test input":
  let input = day13.read_input("./assets/test/input_13.txt")
  check day13.solve_first_part(input) == 17

test "day 14 using test input":
  let (initial, rules) = day14.read_input("./assets/test/input_14.txt")
  check day14.solve_first_part(initial, rules) == 1588
  check day14.solve_second_part(initial, rules) == 2188189693529

test "day 15 using test input":
  let input = day15.read_input("./assets/test/input_15.txt")
  check day15.solve_first_part(input) == 40
  check day15.solve_second_part(input) == 315

test "day 16 using test input":
  var input = day16.read_input("./assets/test/input_16_1.txt")
  check day16.solve_first_part(input) == 16
  check day16.solve_second_part(input) == 15

  input = day16.read_input("./assets/test/input_16_2.txt")
  check day16.solve_first_part(input) == 12
  check day16.solve_second_part(input) == 46

  input = day16.read_input("./assets/test/input_16_3.txt")
  check day16.solve_first_part(input) == 23
  check day16.solve_second_part(input) == 46

  input = day16.read_input("./assets/test/input_16_4.txt")
  check day16.solve_first_part(input) == 31
  check day16.solve_second_part(input) == 54

test "day 17 using test input":
  let
   input = day17.read_input("./assets/test/input_17.txt")
   (solution1, solution2) = day17.solve_both_parts(input)
  check solution1 == 45
  check solution2 == 112


test "day 20 using test input":
  let (algorithm, input) = day20.read_input("./assets/test/input_20.txt")
  check day20.solve_first_part(input, algorithm) == 35
  check day20.solve_second_part(input, algorithm) == 3351
