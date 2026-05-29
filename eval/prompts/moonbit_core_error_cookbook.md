MoonBit Core Error Cookbook Addendum

- MoonBit uses checked errors. A function that may fail declares `raise` or a
  concrete error type such as `raise ParseError`. Calls to raising functions
  propagate automatically inside a raising function; do not add Swift-style
  `try` just to propagate.
- MoonBit has no Rust-style postfix `?` unwrapping for `Result`. To inspect a
  raising call as a result, use `try? f()` and then match `Ok(value)` or
  `Err(error)`.
- Use `catch` when converting internal failures into structured values:
  `parse_value(text) catch { error => Err(error.to_string()) }`.
- Use `try!` only when aborting is acceptable. For user-facing CLIs and parser
  libraries, prefer structured errors and explicit messages over `try!`, `fail`,
  `panic`, or `abort`.
- `fail("message")` raises a generic `Failure`; it is useful in tests but often
  too blunt for library parser errors. Define a small error type when callers
  need line/column/message information.
- `async fn` can raise; handle async file/stdin errors explicitly in CLI code so
  invalid files print clean diagnostics instead of runtime stacks.
- Avoid direct map indexing such as `table[key]` unless the key is guaranteed to
  exist. Use `table.get(key)` and handle `None` to avoid aborts.
- String indexing with `s[i]` returns a `UInt16` code unit. For parsers, prefer
  `s.get_char(i)` for `Char?`, slices such as `s[start:end].to_owned()` for
  owned substrings, or iteration with `for ch in s`.
- A clean CLI failure contract is part of correctness: invalid input should
  produce a predictable message and expected exit behavior, with no MoonBit
  panic/debug stack in stdout or stderr.
