import figchar.{type FIGChar}
import gleam/dict.{type Dict}
import gleam/result
import header.{type Header}
import simplifile as file

pub opaque type FIGFont {
  FIGFont(header: Header, comments: String, fonts: Dict(Int, FIGChar))
}

pub fn read_font_file(filename: String) -> Result(String, Nil) {
  file.read(filename)
  |> result.nil_error
}

pub fn read_header_line(header_line: String) -> Result(Header, String) {
  todo
  // HeaderLine::try_from(header_line)
}
