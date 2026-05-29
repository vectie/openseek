///|
test "system prompt includes moonbit guide" {
  let prompt = base_prompt()
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

///|
test "flash prompt includes flash addenda" {
  let prompt = flash_prompt()
  assert_true(prompt.contains("# Agent Workflow"))
  assert_true(prompt.contains("OpenSeek Flash Addendum"))
  assert_true(prompt.contains("MoonBit Probe Discipline"))
  assert_true(prompt.contains("MoonBit Core Error Cookbook"))
  assert_true(prompt.contains("Do not emit JSON action plans"))
  assert_true(prompt.contains("moon run -e"))
  assert_true(prompt.contains("Do not use `moon run -c`"))
}

///|
test "default prompt is selected per model" {
  assert_true(
    system_prompt_for_model(V4Flash).contains("OpenSeek Flash Addendum"),
  )
  assert_false(
    system_prompt_for_model(V4Pro).contains("OpenSeek Flash Addendum"),
  )
  assert_eq(
    system_prompt_for_model(V4Flash, purpose=Review),
    flash_system_prompt(),
  )
}
