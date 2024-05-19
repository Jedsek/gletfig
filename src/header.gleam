import gleam/int
import gleam/iterator.{type Iterator}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/bool

pub opaque type Header {
  Header(
    line: String,
    // required
    //
    signature: String,
    hardblank: String,
    height: Int,
    baseline: Int,
    max_length: Int,
    old_layout: Int,
    comments_lines: Int,
    // optional
    //
    print_direction: Option(Int),
    full_layout: Option(Int),
    codetag_count: Option(Int),
  )
}

pub fn extract_signature_with_hardblank(
  signature_with_hardblank: String,
) -> Result(#(String, String), String) {
  let len = signature_with_hardblank |> string.length
  case len < 6 {
    True -> Error("can't get signature with hardblank from first line of font")
    False -> {
      let signature = signature_with_hardblank |> string.drop_right(1)
      let hardblank = signature_with_hardblank |> string.drop_left(len - 1)
      Ok(#(signature, hardblank))
    }
  }
}

fn extract_required_info(
  infos: Iterator(String),
  index: Int,
  field: String,
) -> Result(Int, String) {
  let val = infos
    |> iterator.at(index)
    |> result.replace_error("can't get field:" <> field <> "index:" <> {index |> int.to_string} <> "from {}")
  use val <- result.then(val)
  int.parse(val) |> result.map_error(fn(_) { "can't parse required field:{field} of {val} to i32" })
}

fn extract_optional_info(infos: Iterator(String), index: Int, _field: String) -> Option(Int) {
    let val = infos |> iterator.at(index)
    result.then(val, int.parse) |> option.from_result
}

fn try_from(header_line: String) -> Result(Header, String) {
  let infos = header_line |> string.trim |>  string.split(" ") |> iterator.from_list

  use <- bool.guard(when: infos |> iterator.length < 6, return: Error("headerline is illegal"))

  use str <- result.then(infos |> iterator.first |> result.replace_error("no first elem"))
  use signature_with_hardblank <- result.then(str |> extract_signature_with_hardblank)
  use height <- result.then(extract_required_info(infos, 1, "height"))
  use baseline <- result.then(extract_required_info(infos, 2, "baseline"))
  use max_length <- result.then(extract_required_info(infos, 3, "max length"))
  use old_layout <- result.then(extract_required_info(infos, 4, "old layout"))
  use comment_lines <- result.then(extract_required_info(infos, 5, "comment lines"))

  let print_direction = extract_optional_info(infos, 6, "print direction")
  let full_layout = extract_optional_info(infos, 7, "full layout")
  let codetag_count = extract_optional_info(infos, 8, "codetag count")

  Ok(Header (
    header_line,
    signature_with_hardblank.0,
    signature_with_hardblank.1,
    height,
    baseline,
    max_length,
    old_layout,
    comment_lines,
    print_direction,
    full_layout,
    codetag_count,
  ))
}
