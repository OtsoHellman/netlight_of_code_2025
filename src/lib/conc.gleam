import gleam/erlang/process.{type Subject}
import gleam/list

pub type Task(a) {
  Task(subject: Subject(a))
}

pub fn async(fun: fn() -> a) -> Task(a) {
  let subject = process.new_subject()

  process.spawn(fn() {
    let result = fun()
    process.send(subject, result)
  })

  Task(subject)
}

pub fn await_forever(task: Task(a)) -> a {
  let Task(subject) = task
  process.receive_forever(subject)
}

pub fn await(task: Task(a), timeout: Int) -> Result(a, Nil) {
  let Task(subject) = task
  process.receive(subject, timeout)
}

pub fn map(list: List(a), fun: fn(a) -> v) -> List(v) {
  list
  |> list.map(fn(item) { async(fn() { fun(item) }) })
  |> list.map(await_forever)
}

pub fn map_timeout(list: List(a), fun: fn(a) -> v, timeout: Int) -> List(v) {
  list
  |> list.map(fn(item) { async(fn() { fun(item) }) })
  |> list.filter_map(await(_, timeout))
}

pub fn each_timeout(list: List(a), fun: fn(a) -> v, timeout: Int) -> Nil {
  list
  |> list.map(fn(item) { async(fn() { fun(item) }) })
  |> list.each(fn(task) {
    let _ = await(task, timeout)
    Nil
  })
}
