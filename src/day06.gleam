import gleam/int
import gleam/io
import gleam/list
import simplifile
import utils/regexpx

pub fn main() {
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

fn solve() {
  let assert Ok(input) = read_input("input.txt")
  let input = regexpx.get_ints(input)

  let a = traverse(input |> list.take(list.length(input) - 1))
  let b = traverse(input |> list.drop(1))

  int.max(a, b)
  |> int.to_string
}

fn traverse(input: List(Int)) -> Int {
  case input {
    [] -> 0
    [head] -> head
    _ -> {
      let #(_, result) = {
        use #(max_value_2, max_value_1), num <- list.fold(input, #(0, 0))

        let max_value_0 = int.max(max_value_1, max_value_2 + num)

        #(max_value_1, max_value_0)
      }

      result
    }
  }
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day06/" <> filename
  simplifile.read(filepath)
}
