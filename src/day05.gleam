import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/algos
import lib/grid
import simplifile
import utils/resultx

pub fn main() {
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

pub type Node {
  Node(coord: grid.Coord, direction: grid.Direction)
}

fn solve() {
  let assert Ok(input) = read_input("input.txt")

  let input = input |> grid.parse_input_to_string_grid

  let assert Ok(start_coord) = grid.find(input, "S")

  let start_node = Node(start_coord, grid.Right)

  let solution =
    algos.dijkstra(
      start_node,
      is_goal(_, input),
      get_neighbors(_, input),
      update_score,
    )

  solution |> echo

  let final_node = solution |> list.first |> resultx.assert_unwrap
  final_node.1 |> int.to_string
}

fn update_score(node: Node, score: Int, neighbor: Node) -> Int {
  case node.direction == neighbor.direction {
    True -> score + 1
    False ->
      case grid.turn(node.direction, grid.TurnLeft) == neighbor.direction {
        True -> score + 1
        False -> score + 2
      }
  }
}

fn is_goal(node: Node, input: grid.Grid(String)) -> Bool {
  grid.at_assert(input, node.coord) == "E"
}

fn get_neighbors(node: Node, input: grid.Grid(String)) {
  let turn_neighbors = [
    Node(node.coord, grid.turn(node.direction, grid.TurnLeft)),
    Node(node.coord, grid.turn(node.direction, grid.TurnRight)),
  ]

  let move_coord = grid.move(node.coord, node.direction)

  case grid.at(input, move_coord) {
    Ok(value) -> {
      case value {
        "#" -> turn_neighbors
        _ -> list.append(turn_neighbors, [Node(move_coord, node.direction)])
      }
    }
    Error(_) -> turn_neighbors
  }
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day05/" <> filename
  simplifile.read(filepath)
}
