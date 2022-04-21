# Advent of Code 2021

This repository contains all solutions I wrote for the [Advent of Code 2021][1], using Nim as an excuse to learn a new language. Even though it is currently defined as a Nix flake, usual commands for building and running do not work as expected since internet connectivity is off.

Once built, a single binary (`aoc21`) is provided, and it is possible to run all problems solved right from it.

## Installation

Copy the repository and, having Nim and `nimble` as installed dependencies, build the executable:

```shell
nimble build -d:release
```

## Execution

Running the executable requires you to provide a day to choose the problem (using `-d`) and an input file for it (using `-f`). For example:

```shell
./aoc21 -d=21 -f=assets/test/input_21.txt
```