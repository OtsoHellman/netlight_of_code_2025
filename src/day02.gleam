import gleam/int
import gleam/io
import gleam/string
import simplifile

pub fn main() {
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

fn solve() {
  let assert Ok(input) = read_input("input.txt")

  let chars = input |> string.to_graphemes

  chars
  |> asd([], 0)
  |> int.to_string()
}

fn asd(chars: List(String), stack: List(String), matches: Int) -> Int {
  case chars {
    [] -> {
      case stack == [] {
        True -> matches + 1
        False -> matches
      }
    }
    ["{", ..tail] -> asd(tail, ["{", ..stack], matches)
    ["}", ..tail] ->
      case stack {
        [] -> matches
        [stack_head, ..stack_tail] ->
          case stack_head {
            "{" -> asd(tail, stack_tail, matches + 1)
            _ -> matches
          }
      }
    ["[", ..tail] -> asd(tail, ["[", ..stack], matches)
    ["]", ..tail] ->
      case stack {
        [] -> matches
        [stack_head, ..stack_tail] ->
          case stack_head {
            "[" -> asd(tail, stack_tail, matches + 1)
            _ -> matches
          }
      }
    ["(", ..tail] -> asd(tail, ["(", ..stack], matches)
    [")", ..tail] ->
      case stack {
        [] -> matches
        [stack_head, ..stack_tail] ->
          case stack_head {
            "(" -> asd(tail, stack_tail, matches + 1)
            _ -> matches
          }
      }
    [_, ..tail] -> asd(tail, stack, matches)
  }
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day02/" <> filename
  simplifile.read(filepath)
}
