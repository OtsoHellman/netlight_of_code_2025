import gleam/erlang/atom.{type Atom}

pub opaque type Cache(k, v) {
  Cache(table: Int)
}

@external(erlang, "ets", "new")
fn ets_new(name: Atom, options: List(Atom)) -> Int

@external(erlang, "ets", "insert")
fn ets_insert(table: Int, object: #(k, v)) -> Bool

@external(erlang, "ets", "lookup")
fn ets_lookup(table: Int, key: k) -> List(#(k, v))

@external(erlang, "ets", "whereis")
fn ets_whereis_dynamic(name: Atom) -> a

@external(erlang, "erlang", "binary_to_atom")
fn string_to_atom(str: String) -> Atom

fn is_undefined(value: a) -> Bool {
  let undefined = string_to_atom("undefined")
  do_is_equal(value, undefined)
}

@external(erlang, "erlang", "=:=")
fn do_is_equal(a: a, b: b) -> Bool

fn create_named(name: String) -> Cache(k, v) {
  let table_name = string_to_atom(name)
  let options = [
    string_to_atom("named_table"),
    string_to_atom("public"),
    string_to_atom("set"),
  ]
  let table_id = ets_new(table_name, options)
  Cache(table_id)
}

pub fn create() -> Cache(k, v) {
  create_named("aoc_cache")
}

fn get(cache: Cache(k, v), key: k) -> Result(v, Nil) {
  let Cache(table) = cache
  case ets_lookup(table, key) {
    [#(_, value), ..] -> Ok(value)
    [] -> Error(Nil)
  }
}

fn set(cache: Cache(k, v), key: k, value: v) -> Nil {
  let Cache(table) = cache
  ets_insert(table, #(key, value))
  Nil
}

pub fn memoize(cache: Cache(k, v), key: k, fun: fn() -> v) -> v {
  case get(cache, key) {
    Ok(value) -> value
    Error(_) -> {
      let value = fun()
      set(cache, key, value)
      value
    }
  }
}

fn whereis(name: String) -> Result(Cache(k, v), Nil) {
  let table_name = string_to_atom(name)
  let result = ets_whereis_dynamic(table_name)

  case is_undefined(result) {
    True -> Error(Nil)
    False -> {
      let table_id = unsafe_coerce(result)
      Ok(Cache(table_id))
    }
  }
}

@external(erlang, "cache_ffi", "identity")
fn unsafe_coerce(a: a) -> b

pub fn try_memo(key: k, fun: fn() -> v) -> v {
  case whereis("aoc_cache") {
    Ok(cache) -> memoize(cache, key, fun)
    Error(_) -> fun()
  }
}

pub fn assert_memo(key: k, fun: fn() -> v) -> v {
  let assert Ok(cache) = whereis("aoc_cache")
  memoize(cache, key, fun)
}
