import gleam/bool
import gleam/int
import gleam/io
import gleam/list
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

  let orders = lines |> list.map(parse_order)

  let groups =
    get_groups(orders)
    |> list.map(list.sort(_, fn(a, b) { int.compare(a.time, b.time) }))

  groups
  |> list.map(get_group_score(_, [], -2020, 0))
  |> int.sum
  |> int.to_string
}

fn get_group_score(
  orders: List(Order),
  interval_orders: List(Order),
  prev_interval: Int,
  result: Int,
) {
  case orders {
    [] -> result + get_interval_score(interval_orders)
    [head, ..tail] -> {
      case head.time - prev_interval <= 5 {
        False -> {
          let interval_score = get_interval_score(interval_orders)
          let result = result + interval_score
          let prev_interval = head.time
          get_group_score(tail, [head], prev_interval, result)
        }
        True -> {
          let interval_orders = list.append(interval_orders, [head])

          get_group_score(tail, interval_orders, prev_interval, result)
        }
      }
    }
  }
}

fn get_interval_score(orders: List(Order)) {
  use <- bool.guard(list.is_empty(orders), 0)

  let score =
    orders
    |> list.map(fn(order) { get_score(order.drink) })
    |> int.sum

  let score = score - list.length(orders) + 1

  score
}

fn get_drinks() {
  ["espresso", "americano", "latte", "cappuccino", "mocha"]
}

fn get_sizes() {
  ["small", "medium", "large"]
}

fn get_score(drink: String) {
  case drink {
    "espresso" -> 1
    "americano" -> 2
    "cappuccino" -> 3
    "latte" -> 3
    "mocha" -> 4
    c -> {
      panic
    }
  }
}

fn get_groups(orders: List(Order)) -> List(List(Order)) {
  let drinks = get_drinks()
  let sizes = get_sizes()

  let groups =
    drinks
    |> list.flat_map(fn(drink) {
      sizes
      |> list.map(fn(size) {
        orders
        |> list.filter(fn(order) { order.drink == drink && order.size == size })
      })
    })

  groups |> list.filter(fn(group) { !list.is_empty(group) })
}

fn parse_order(line: String) -> Order {
  let assert [drink, size, time_str] = string.split(line, ",")
  Order(drink, size, intx.parse(time_str))
}

type Order {
  Order(drink: String, size: String, time: Int)
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day07/" <> filename
  simplifile.read(filepath)
}
