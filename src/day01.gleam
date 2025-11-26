import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let part1 = solve1()
  io.println("\nPart 1 solution:")
  io.println(part1)

  let part2 = solve2()
  io.println("\nPart 2 solution:")
  io.println(part2)

  let part3 = solve3()
  io.println("\nPart 3 solution:")
  io.println(part3)
}

fn solve1() {
  let assert Ok(input) = read_input("input1.txt")

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

fn solve2() {
  let assert Ok(_input) = read_input("input2.txt")

  "TODO"
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

fn solve3() {
  let assert Ok(_input) = read_input("input3.txt")

  "TODO"
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day01/" <> filename
  simplifile.read(filepath)
}
