import std/[hashes, strutils, strformat, sequtils, tables]

type
  Node = ref object
    id: string
    is_big_cave: bool
    connected: seq[Node]
  Path = seq[Node]
  Graph = object
    start_node: Node
    end_node: Node
    nodes: Table[string, Node]

proc get_or_create(graph: var Graph, id: string): Node =
  ## Get or create the node in the graph object.
  if id in graph.nodes:
    return graph.nodes[id]
  else:
    var node = Node(
      id: id,
      is_big_cave: id.all(is_upper_ascii)
    )
    graph.nodes[id] = node
    return node

proc read_input*(path: string): Graph =
  ## Parse the input file into a graph object.
  var graph = Graph(nodes: init_table[string, Node]())

  for line in read_file(path).split("\n"):
    if line != "":
      let ids = line.split("-")

      var
        node_a = graph.get_or_create(ids[0])
        node_b = graph.get_or_create(ids[1])

      node_a.connected.add(node_b)
      node_b.connected.add(node_a)

  graph.start_node = graph.get_or_create("start")
  graph.end_node = graph.get_or_create("end")

  return graph

proc explore(node: Node, visited: Path = @[], twice_once: bool = false): seq[Path] =
  ## Generate all possible paths from this node to the end node.
  ##
  ## This function recursively explores all possible paths from the current
  ## node to the end node. The `twice_once` parameter allows to visit a small
  ## cave twice only once in the path (big caves can be visited as many times
  ## as required).

  # TODO: could improve performance using dynamic programming
  let current_path = visited & @[node]

  # If this is the end node, the current path is over.
  if node.id == "end":
    return @[current_path]

  # Explore all connected nodes and return the sequence of paths.
  var paths: seq[Path] = @[]
  for node in node.connected:
    if node.is_big_cave or node notin visited:
      paths = paths & node.explore(current_path, twice_once)
    elif twice_once and node.id != "start":
      paths = paths & node.explore(current_path, false)

  return paths

proc solve_first_part*(input: Graph): int =
  ## Solve the first part counting paths that never visit a small cave twice.
  let paths = input.start_node.explore(twice_once = false)
  return len(paths)

proc solve_second_part*(input: Graph): int =
  ## Solve the second part counting paths that visit a small cave twice only
  ## once.
  let paths = input.start_node.explore(twice_once = true)
  return len(paths)

proc solve*(path: string) =
  ## Solve the Day 11 problem and output
  var input = read_input(path)
  let solution_1 = solve_first_part(input)
  echo(&"Solution to the first part: {solution_1}")
  let solution_2 = solve_second_part(input)
  echo(&"Solution to the second part: {solution_2}")
