import gleam/bool
import gleam/io
import gleam/iterator.{type Iterator}
import gleam/result
import gleam/string

pub opaque type FIGChar {
  FIGChar(code: Int, chars: Iterator(String), width: Int, height: Int)
}

pub opaque type FIGure {
  FIGure(chars: Iterator(FIGChar), height: Int)
}

pub fn is_not_empty(self: FIGure) -> Bool {
  { self.chars |> iterator.length > 0 } && self.height > 0
}

pub fn print(self: FIGure) {
  use <- bool.guard(when: !is_not_empty(self), return: io.print(""))

  use i <- iterator.each(iterator.range(0, self.height))
  let lines = {
    use figchar <- iterator.map(self.chars)
    figchar.chars |> iterator.at(i) |> result.unwrap("")
  }
  let lines =
    iterator.append(lines, iterator.from_list(["\n"]))
    |> iterator.to_list
    |> string.join(with: "")

  io.print(lines)
}
