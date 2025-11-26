import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/cache
import simplifile
import utils/intx

pub fn main() {
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

fn solve() {
  cache.create()
  let assert Ok(input) = read_input("input.txt")

  let lines = input |> string.split("\n")

  let assert [line1, line2] = lines
  let assert [max_transactions, transaction_fee] =
    line1 |> string.split(" ") |> list.map(intx.parse)
  let prices = line2 |> string.split(" ") |> list.map(intx.parse)

  get_max_profit(prices, max_transactions, transaction_fee, 0, 0)
  |> int.to_string
}

fn get_max_profit(
  prices: List(Int),
  remaining_transactions: Int,
  transaction_fee: Int,
  profit: Int,
  active_share: Int,
) {
  use <- bool.guard(remaining_transactions <= 0, profit)
  use <- cache.assert_memo(#(
    prices,
    remaining_transactions,
    profit,
    active_share,
  ))

  case prices {
    [] -> profit
    [head, ..tail] -> {
      case active_share {
        x if x <= 0 -> {
          let buy =
            get_max_profit(
              tail,
              remaining_transactions,
              transaction_fee,
              profit,
              head,
            )
          let skip =
            get_max_profit(
              tail,
              remaining_transactions,
              transaction_fee,
              profit,
              active_share,
            )
          int.max(buy, skip)
        }
        _ -> {
          let sell_profit = profit + { head - active_share - transaction_fee }
          let sell =
            get_max_profit(
              tail,
              remaining_transactions - 1,
              transaction_fee,
              sell_profit,
              0,
            )
          let skip =
            get_max_profit(
              tail,
              remaining_transactions,
              transaction_fee,
              profit,
              active_share,
            )
          int.max(sell, skip)
        }
      }
    }
  }
}

fn read_input(filename: String) -> Result(String, simplifile.FileError) {
  let filepath = "inputs/day08/" <> filename
  simplifile.read(filepath)
}
