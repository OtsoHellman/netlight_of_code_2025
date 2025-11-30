import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/set
import lib/algos_new
import lib/conc
import lib/grid
import simplifile

pub fn main() {
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

fn solve() {
  let assert Ok(input) = read_input("input.txt")

  let input = grid.parse_input_to_int_grid(input)

  let size = grid.length(input)

  let max_x = size.0 - 1
  let max_y = size.1 - 1
  let min_x = 0
  let min_y = 0

  let edges = Edges(max_x, max_y, min_x, min_y)

  let edge_coords = get_edges(edges) |> set.from_list
  let all_coords = grid.get_coords(input)

  let result = solve_dijkstra_for_all_edges(input, edge_coords, all_coords)
  result |> int.to_string
}

fn solve_dijkstra_for_all_edges(
  input: grid.Grid(Int),
  edge_coords: set.Set(grid.Coord),
  all_coords: List(grid.Coord),
) {
  all_coords
  |> conc.map(solve_dijkstra_for_coord(input, edge_coords, _))
  |> int.sum
}

fn solve_dijkstra_for_coord(
  input: grid.Grid(Int),
  edge_coords: set.Set(grid.Coord),
  coord: grid.Coord,
) {
  let result =
    algos_new.dijkstra(
      coord,
      fn(c) { set.contains(edge_coords, c) },
      get_neighbors(input, _),
      fn(_, score, neighbor) { update_score(input, coord, score, neighbor) },
    )
  result
}

fn get_neighbors(input: grid.Grid(Int), coord: grid.Coord) {
  grid.get_neighbors(input, coord, grid.Orthogonal) |> list.map(pair.first)
}

fn update_score(
  input: grid.Grid(Int),
  node: grid.Coord,
  score: Int,
  neighbor: grid.Coord,
) -> Int {
  let current_height = grid.at_assert(input, node)
  let neighbor_height = grid.at_assert(input, neighbor)

  let prev_max_height = current_height + score

  case neighbor_height - prev_max_height {
    diff if 0 < diff -> score + diff
    _ -> score
  }
}

type Edges {
  Edges(max_x: Int, max_y: Int, min_x: Int, min_y: Int)
}

fn get_edges(edges: Edges) {
  let Edges(max_x, max_y, min_x, min_y) = edges

  let top_edge = list.range(min_x, max_x) |> list.map(fn(x) { #(x, max_y) })
  let bottom_edge = list.range(min_x, max_x) |> list.map(fn(x) { #(x, min_y) })
  let left_edge = list.range(min_y, max_y) |> list.map(fn(y) { #(min_x, y) })
  let right_edge = list.range(min_y, max_y) |> list.map(fn(y) { #(max_x, y) })

  top_edge
  |> list.append(bottom_edge)
  |> list.append(left_edge)
  |> list.append(right_edge)
  |> list.unique
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day10/" <> filename
  simplifile.read(filepath)
}
