///|
test "system prompt includes moonbit guide" {
  let prompt = system_prompt()
  assert_true(prompt.contains("# Agent Workflow"))
  assert_true(prompt.contains("MoonBit Error Handling"))
  assert_true(prompt.contains("--warn-list +unnecessary_annotation"))
  assert_true(prompt.contains("moon run -e"))
  assert_false(prompt.contains("moon run -c"))
  assert_true(prompt.contains("cache-friendly"))
  assert_true(prompt.contains("moon_ide outline"))
  assert_true(prompt.contains("start_line"))
  assert_true(prompt.contains("flat like Go packages"))
  assert_true(prompt.contains("generated native/C entry path"))
  assert_true(prompt.contains("create `moon.mod`, not `moon.mod.json`"))
  assert_true(prompt.contains("After editing `moon.mod`, `moon.pkg`"))
  assert_true(prompt.contains("acceptance probes"))
  assert_true(prompt.contains("file arguments are read as files"))
  assert_true(prompt.contains("OpenSeek DeepSeek Addendum"))
}
