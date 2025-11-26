import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile
import utils/intx

pub fn main() {
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

fn solve() {
  let assert Ok(input) = read_input("input.txt")

  let lines = input |> string.split("\n")

  let entries =
    lines
    |> list.map(parse_line)

  let sorted_entries =
    entries
    |> list.sort(fn(a, b) {
      case int.compare(a.time, b.time) {
        order.Eq -> {
          case a.action == b.action {
            True -> order.Eq
            False -> {
              case a.action {
                "OUT" -> order.Gt
                "IN" -> order.Lt
                _ -> panic
              }
            }
          }
        }
        other -> other
      }
    })

  let total_time = get_trios(sorted_entries, [], 0, 0)

  total_time |> int.to_string
}

fn get_trios(
  entries: List(Entry),
  current_visitors: List(String),
  time: Int,
  result: Int,
) {
  case entries {
    [] -> result
    [head, ..tail] -> {
      case head.action {
        "IN" -> {
          case list.contains(current_visitors, head.name) {
            True -> get_trios(tail, current_visitors, time, result)
            False -> {
              case list.length(current_visitors) {
                3 -> {
                  let new_visitors = list.append(current_visitors, [head.name])

                  let added_time = head.time - time
                  let new_result = result + added_time
                  get_trios(tail, new_visitors, head.time, new_result)
                }
                _ -> {
                  let new_visitors = list.append(current_visitors, [head.name])

                  case list.length(new_visitors) {
                    3 -> get_trios(tail, new_visitors, head.time, result)
                    _ -> get_trios(tail, new_visitors, time, result)
                  }
                }
              }
            }
          }
        }
        "OUT" -> {
          case list.contains(current_visitors, head.name) {
            True -> {
              case list.length(current_visitors) {
                3 -> {
                  let new_visitors =
                    list.filter(current_visitors, fn(n) { n != head.name })
                  let added_time = head.time - time
                  let new_result = result + added_time
                  get_trios(tail, new_visitors, head.time, new_result)
                }
                _ -> {
                  let new_visitors =
                    list.filter(current_visitors, fn(n) { n != head.name })

                  case list.length(new_visitors) {
                    3 -> get_trios(tail, new_visitors, head.time, result)
                    _ -> get_trios(tail, new_visitors, time, result)
                  }
                }
              }
            }
            False -> get_trios(tail, current_visitors, time, result)
          }
        }
        _ -> panic
      }
    }
  }
}

type Entry {
  Entry(time: Int, name: String, action: String)
}

fn parse_line(line: String) {
  let assert [time, name, action] = string.split(line, " ")
  let assert [hour, minute] = string.split(time, ":")

  let time = intx.parse(hour) * 60 + intx.parse(minute)

  Entry(time, name, action)
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day03/" <> filename
  simplifile.read(filepath)
}
