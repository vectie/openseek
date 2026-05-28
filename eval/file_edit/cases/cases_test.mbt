///|
test "case rotation repeats cases in order" {
  assert_eq(@cases.case_for_trial(0).id, "exact_replace")
  assert_eq(@cases.case_for_trial(4).id, "compile_fix")
  assert_eq(@cases.case_for_trial(5).id, "exact_replace")
}

///|
test "case task includes workspace and marker" {
  let case = @cases.case_for_trial(0)
  let task = case.task("/tmp/workspace")
  assert_true(task.contains("Workspace: /tmp/workspace"))
  assert_true(task.contains("file-edit-eval:exact_replace"))
  assert_true(task.contains("absolute path under the Workspace"))
}
