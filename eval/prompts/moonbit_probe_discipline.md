MoonBit Probe Discipline Addendum

- MoonBit syntax and library details are easy to misremember. When unsure, run
  a small probe before editing real project files.
- Prefer `moon run -e` for one-line probes. Do not use `moon run -c`; it is
  confusing with `moon -C` and is not the documented spelling.
- In OpenSeek, run MoonBit probes through the `moon_cmd` tool:
  `{"command":"run","args":["-e","fn main { println(\"ok\") }"]}`.
- For multi-line probes, prefer stdin:
  `{"command":"run","path":"-","stdin":"fn main {\n  println(\"ok\")\n}\n"}`.
- Treat probe failures as feedback. Correct the syntax or API assumption and
  probe again before making broad edits.
