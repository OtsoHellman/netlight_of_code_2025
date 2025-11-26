// ETS table reference type (phantom type to track key/value types)
pub opaque type Cache(k, v) {
  Cache(table: Int)
}

// ETS table options
type TableOptions

// Direct Erlang FFI bindings
@external(erlang, "ets", "new")
fn ets_new(name: atom, options: List(TableOptions)) -> Int

@external(erlang, "ets", "insert")
fn ets_insert(table: Int, object: #(k, v)) -> Bool

@external(erlang, "ets", "lookup")
fn ets_lookup(table: Int, key: k) -> List(#(k, v))

// Helper to create atom from string
@external(erlang, "erlang", "binary_to_atom")
fn string_to_atom(str: String) -> atom

// Table option constructors
@external(erlang, "ffi", "named_table")
fn named_table() -> TableOptions

@external(erlang, "ffi", "public_table")
fn public_table() -> TableOptions

@external(erlang, "ffi", "set_table")
fn set_table() -> TableOptions

pub fn create_named(name: String) -> Cache(k, v) {
  let table_name = string_to_atom(name)
  let options = [named_table(), public_table(), set_table()]
  let table_id = ets_new(table_name, options)
  Cache(table_id)
}

pub fn create() -> Cache(k, v) {
  create_named("aoc_cache")
}

pub fn get(cache: Cache(k, v), key: k) -> Result(v, Nil) {
  let Cache(table) = cache
  case ets_lookup(table, key) {
    [#(_, value), ..] -> Ok(value)
    [] -> Error(Nil)
  }
}

pub fn set(cache: Cache(k, v), key: k, value: v) -> Nil {
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
