import gleam/int
import gleam/io
import gleam/list
import lib/cache

pub fn main() {
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

fn solve() {
  cache.create()

  let input = [1, 5, 3, 6, 7]

  let result =
    input
    |> list.map(fn(x) { get_total(x, 365) })
    |> int.sum

  result + list.length(input) |> int.to_string
}

fn get_total(x: Int, counter: Int) {
  use <- cache.assert_memo(#(x, counter))

  let #(double_times, spawns) = spawn_times(x, [], 0, counter)

  let spawn_total = list.map(spawns, fn(spawn) { get_total(10, spawn) })

  double_times + int.sum(spawn_total)
}

fn spawn_times(x: Int, spawns: List(Int), double_times: Int, counter: Int) {
  let new_spawn = counter - x

  case new_spawn {
    n if n <= 0 -> #(double_times, spawns)
    _ ->
      spawn_times(
        7,
        list.append(spawns, [new_spawn]),
        double_times + 1,
        new_spawn,
      )
  }
}
