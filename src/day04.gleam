import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/cache
import simplifile
import utils/regexpx

pub fn main() {
  let result = solve()
  io.println("\nsolution:")
  io.println(result)
}

fn solve() {
  let cache = cache.create()

  let input = [1, 5, 3, 6, 7]
  // let input = [1, 5, 6, 9, 7]

  let result =
    input
    |> list.map(fn(x) { get_total(x, 365, cache) })
    |> int.sum

  result + list.length(input) |> int.to_string
}

// fn step(input: List(Int)) {
//   let new_input =
//     input
//     |> list.map(fn(x) { x - 1 })

//   let #(news, new_input) =
//     list.map_fold(new_input, 0, fn(acc, x) {
//       case x {
//         x if x <= 0 -> #(acc + 1, 6)
//         _ -> #(acc, x)
//       }
//     })

//   let final_input = list.append(new_input, list.repeat(9, news))

//   final_input
// }

fn get_total(x: Int, counter: Int, cache) {
  use <- cache.memoize(cache, #(x, counter))

  let #(double_times, spawns) = spawn_times(x, [], 0, counter)

  let spawn_total = list.map(spawns, fn(spawn) { get_total(10, spawn, cache) })

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
