import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import lib/cache
import lib/grid
import simplifile
import utils/listx
import utils/regexpx
import utils/resultx

pub fn main() {
  cache.create()
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

type Edges {
  Edges(left: Int, right: Int, top: Int, bottom: Int)
}

fn coord_to_edges(coord: grid.Coord) -> Edges {
  let #(x, y) = coord
  Edges(left: x, right: x, top: y, bottom: y)
}

fn solve() {
  let assert Ok(input) = read_input("input.txt")

  let input = grid.parse_input_to_string_grid(input)

  // 951 868
  // let promising_coords = #(868, 49)

  let promising_coords = get_promising_coords()

  let result =
    promising_coords
    |> list.map(coord_to_edges)
    |> list.map(fn(edges) { get_largest_rectangle(input, edges) })

  listx.max_by(result, fn(a) { a })
  |> int.to_string
}

fn get_largest_rectangle(input: grid.Grid(String), edges: Edges) -> Int {
  use <- cache.assert_memo(edges)
  let directions = grid.get_directions(grid.Orthogonal)

  let new_edges =
    directions
    |> list.map(fn(direction) {
      get_new_edges_for_direction(input, edges, direction)
    })

  let valid_extensions =
    new_edges
    |> list.filter(result.is_ok)
    |> list.map(resultx.assert_unwrap)

  case valid_extensions {
    [] -> {
      let width = edges.right - edges.left + 1
      let height = edges.top - edges.bottom + 1
      width * height
    }
    _ -> {
      let new_extensions =
        valid_extensions
        |> list.map(fn(new_edges) { get_largest_rectangle(input, new_edges) })

      listx.max_by(new_extensions, fn(a) { a })
    }
  }
}

fn get_new_edges_for_direction(
  input: grid.Grid(String),
  edges: Edges,
  direction: grid.Direction,
) {
  let left = edges.left
  let right = edges.right
  let top = edges.top
  let bottom = edges.bottom

  let coords_to_check = case direction {
    grid.Up -> {
      list.range(left, right)
      |> list.map(fn(x) { #(x, top + 1) })
    }
    grid.Down -> {
      list.range(left, right)
      |> list.map(fn(x) { #(x, bottom - 1) })
    }
    grid.Left -> {
      list.range(top, bottom)
      |> list.map(fn(y) { #(left - 1, y) })
    }
    grid.Right -> {
      list.range(top, bottom)
      |> list.map(fn(y) { #(right + 1, y) })
    }
    _ -> panic
  }

  let new_coords =
    coords_to_check
    |> list.map(grid.at(input, _))
    |> result.all

  case new_coords {
    Ok(new_coords) -> {
      case new_coords |> list.all(fn(v) { v == "*" }) {
        True -> {
          case direction {
            grid.Up ->
              Ok(Edges(left: left, right: right, top: top + 1, bottom: bottom))
            grid.Down ->
              Ok(Edges(left: left, right: right, top: top, bottom: bottom - 1))
            grid.Left ->
              Ok(Edges(left: left - 1, right: right, top: top, bottom: bottom))
            grid.Right ->
              Ok(Edges(left: left, right: right + 1, top: top, bottom: bottom))
            _ -> panic
          }
        }
        False -> Error(Nil)
      }
    }
    Error(_) -> {
      Error(Nil)
    }
  }
}

// fn get_neighbors_for_direction(
//   input: grid.Grid(String),
//   coords: List(grid.Coord),
//   direction: grid.Direction,
// ) {
//   let neighbors =
//     coords |> list.map(grid.try_move(input, _, direction)) |> result.all

//   case neighbors {
//     Ok(neighbors) -> {
//       case
//         neighbors |> list.all(fn(coord) { grid.at_assert(input, coord) == "*" })
//       {
//         True -> Ok(neighbors)
//         False -> Error(Nil)
//       }
//     }
//     Error(_) -> {
//       Error(Nil)
//     }
//   }
// }

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day09/" <> filename
  simplifile.read(filepath)
}

fn get_promising_coords() {
  "18 976
30 414
49 13
146 203
287 861
262 698
314 74
373 62
471 708
501 723
509 276
590 585
553 479
593 220
847 804
951 868"
  |> string.split("\n")
  |> list.map(regexpx.get_positive_ints)
  |> list.map(fn(nums) {
    case nums {
      [y, x] -> #(x, 1000 - y)
      _ -> panic
    }
  })
}
