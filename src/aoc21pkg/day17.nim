import std/[re, strutils, strformat]

type
  Point = tuple
    x, y: int
  Velocity = tuple
    dx, dy: int
  Target = object
    min_p: Point
    max_p: Point
  Probe = object
    position: Point
    velocity: Velocity
  Trajectory = object
    points: seq[Point]
    apex: int
    hit: bool

proc read_input*(path: string): Target =
  ## Parse the input file into a target area.
  var matches: array[4, string]

  let
    re = re"target area: x=(-?\d*)..(-?\d*), y=(-?\d*)..(-?\d*)"
    does_match = read_file(path).match(re, matches)

  if does_match:
    return Target(
        min_p: (matches[0].parse_int(), matches[2].parse_int()),
        max_p: (matches[1].parse_int(), matches[3].parse_int())
    )
  else:
    raise newException(ValueError, "invalid input")

proc add(trajectory: var Trajectory, point: Point) =
  ## Add a point to a trajectory and update the apex if needed.
  trajectory.points.add(point)

  if point.y > trajectory.apex:
    trajectory.apex = point.y

proc `in`(p: Point, t: Target): bool =
  ## Check if a point is inside the target area or not.
  p.x in t.min_p.x..t.max_p.x and p.y in t.min_p.y..t.max_p.y

proc move(probe: var Probe) =
  ## Move a probe to the next point.
  probe.position.x += probe.velocity.dx
  probe.position.y += probe.velocity.dy

proc accelerate(probe: var Probe) =
  ## Update the probe velocity to the next step.
  if probe.velocity.dx > 0:
    probe.velocity.dx -= 1
  elif probe.velocity.dx < 0:
    probe.velocity.dx += 1

  probe.velocity.dy -= 1

proc shoot(probe: Probe, target: Target): Trajectory =
  ## Shoot a probe to a target.
  var
    probe = probe
    last_point = probe.position
    trajectory: Trajectory

  while last_point.x <= target.max_p.x and last_point.y >= target.min_p.y:
    probe.move()
    probe.accelerate()

    trajectory.add(probe.position)
    last_point = probe.position

    if last_point in target:
      trajectory.hit = true
      break

  return trajectory

proc find_best_dx(probe: var Probe,
                  dy: int,
                  target: Target,
                  counter: var int = 0): Trajectory =
  ## Find the best dx for a given dy in a launch.
  ##
  ## This function samples the whole space of possibilities because it uses
  ## `counter` to check how many dx actually hit the target.
  var
    hit_yet: bool
    last_best: Trajectory

  probe.velocity = (0, dy)

  while probe.velocity.dx <= target.max_p.x:
    probe.velocity.dx.inc()

    let trajectory = probe.shoot(target)

    if trajectory.hit:
      counter.inc()
      hit_yet = true
      if trajectory.apex > last_best.apex:
        last_best = trajectory

  return last_best

proc find_highest_apex(target: Target): (int, int) =
  ## Find the highest apex possible when shooting for a target.
  ##
  ## This function brute forces all possibilities and then returns the highest
  ## point reachable while hitting a target area. The second value it returns
  ## is the count of all possible velocities that can still hit the target
  ## area.
  var
    counter = 0
    last_dy = target.min_p.y
    last_best: Trajectory

  while last_dy <= abs(target.min_p.y):
    var probe = Probe(position: (0, 0))
    let trajectory = probe.find_best_dx(last_dy, target, counter)

    if trajectory.hit and trajectory.apex > last_best.apex:
      last_best = trajectory

    last_dy.inc()

  return (last_best.apex, counter)

proc solve_both_parts*(target: Target): (int, int) =
  ## Solve both parts and return both values.
  target.find_highest_apex()

proc solve*(path: string) =
  ## Solve the Day 17 problem and output.
  var input = read_input(path)
  let (solution_1, solution_2) = solve_both_parts(input)
  echo(&"Solution to the first part: {solution_1}")
  echo(&"Solution to the second part: {solution_2}")
