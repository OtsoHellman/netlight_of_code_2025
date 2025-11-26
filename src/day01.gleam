import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

fn solve() {
  let assert Ok(input) = read_input("input.txt")

  let alphabet = [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
  ]

  let strings =
    input
    |> string.split("\n")
    |> list.map(string.trim)
    |> list.map(string.lowercase)
    |> list.map(fn(s) {
      s
      |> string.to_graphemes
      |> list.map(fn(c) {
        case list.contains(alphabet, c) {
          True -> c
          False -> ""
        }
      })
      |> string.join("")
    })

  strings |> list.count(is_palindrome) |> int.to_string
}

fn reverse_string(s: String) {
  s
  |> string.to_graphemes
  |> list.reverse
  |> string.join("")
}

fn is_palindrome(s: String) {
  s == reverse_string(s)
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day01/" <> filename
  simplifile.read(filepath)
}
