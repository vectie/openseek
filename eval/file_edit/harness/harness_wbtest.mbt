///|
async test "dry run exact replacement oracle" {
  let case = @cases.case_for_trial(0)
  let root = @fs.tmpdir(prefix="openseek-file-edit-harness")
  let workspace = root + "/workspace"
  let log_path = root + "/trial.log"
  @fs.mkdir(workspace, recursive=true)
  write_fixture(workspace, case)
  @vfs.FileSystem({ "src/note.txt": "alpha\ndelta\ngamma\n" }).write_to(
    workspace,
  )
  @fs.write_file(
    log_path,
    (
      $|--- step 1 ---
      $|tool: ok: replaced 1 occurrence
      $|=== finished ===
      $|file-edit-eval:\{case.id}
    ),
    create_mode=CreateOrTruncate,
  )
  let result = evaluate_trial(
    0,
    case,
    workspace,
    log_path,
    0,
    @fs.read_file(log_path).text(),
  )
  assert_true(result.success)
  assert_eq(result.reason, "ok")
  assert_eq(result.edit_successes, 1)
  assert_true(result.marker_present)
  let _ = @fs.rmdir(root, recursive=true) catch { _ => () }
}

///|
test "count_occurrences counts non-overlapping markers" {
  assert_eq(count_occurrences("tool error: a\ntool error: b", "tool error:"), 2)
  assert_eq(count_occurrences("abc", "z"), 0)
}

///|
test "markdown report summarizes threshold" {
  let report : EvalReport = {
    model: "deepseek-v4-flash",
    runs: 1,
    min_successes: 1,
    successes: 1,
    out_dir: "out",
    results: [
      {
        index: 1,
        case_id: "exact_replace",
        success: true,
        reason: "ok",
        workspace: "ws",
        log_path: "log",
        exit_code: 0,
        steps: 3,
        tool_errors: 0,
        shell_uses: 0,
        edit_successes: 1,
        write_successes: 0,
        validation_passed: true,
        marker_present: true,
        warnings: "",
      },
    ],
  }
  let text = report.markdown()
  assert_true(text.contains("1/1"))
  assert_true(text.contains("exact_replace"))
}
