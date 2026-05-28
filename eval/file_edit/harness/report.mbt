///|
async fn write_report_files(report : EvalReport) -> Unit {
  @fs.write_file(
    report.out_dir + "/report.json",
    report.to_json().stringify(),
    create_mode=CreateOrTruncate,
  )
  @fs.write_file(
    report.out_dir + "/report.md",
    report.markdown(),
    create_mode=CreateOrTruncate,
  )
}

///|
fn EvalReport::to_json(self : EvalReport) -> Json {
  {
    "model": self.model,
    "runs": self.runs,
    "min_successes": self.min_successes,
    "successes": self.successes,
    "passed": self.passed(),
    "out_dir": self.out_dir,
    "results": ([ for result in self.results => result.to_json() ] : Json),
  }
}

///|
fn TrialResult::to_json(self : TrialResult) -> Json {
  {
    "index": self.index,
    "case_id": self.case_id,
    "success": self.success,
    "reason": self.reason,
    "workspace": self.workspace,
    "log_path": self.log_path,
    "exit_code": self.exit_code,
    "steps": self.steps,
    "tool_errors": self.tool_errors,
    "shell_uses": self.shell_uses,
    "edit_successes": self.edit_successes,
    "write_successes": self.write_successes,
    "validation_passed": self.validation_passed,
    "marker_present": self.marker_present,
    "warnings": self.warnings,
  }
}

///|
pub fn EvalReport::passed(self : EvalReport) -> Bool {
  self.successes >= self.min_successes
}

///|
pub fn EvalReport::failure_message(self : EvalReport) -> String {
  "file edit eval failed: \{self.successes}/\{self.runs} below threshold \{self.min_successes}/\{self.runs}"
}

///|
pub fn EvalReport::markdown(self : EvalReport) -> String {
  let lines : Array[String] = [
    (
      $|# File Edit Eval
      $|
      $|- model: `\{self.model}`
      $|- result: `\{self.successes}/\{self.runs}` successes
      $|- threshold: `\{self.min_successes}/\{self.runs}`
      $|- passed: `\{self.passed()}`
      $|- output: `\{self.out_dir}`
      $|
      $|| # | Case | Result | Steps | Tool Errors | Shell Uses | Reason | Warnings |
      $|| --- | --- | --- | ---: | ---: | ---: | --- | --- |
    ),
  ]
  for result in self.results {
    lines.push(
      "| \{result.index} | `\{result.case_id}` | \{if result.success { "pass" } else { "fail" }} | \{result.steps} | \{result.tool_errors} | \{result.shell_uses} | \{escape_table_cell(result.reason)} | \{escape_table_cell(result.warnings)} |",
    )
  }
  lines.push(
    (
      $|
      $|## Logs
      $|
    ),
  )
  for result in self.results {
    lines.push(
      "- `\{result.case_id}` trial \{result.index}: `\{result.log_path}`",
    )
  }
  lines.join("\n") + "\n"
}

///|
fn escape_table_cell(text : String) -> String {
  text
  |> String::replace_all(old="|", new="\\|")
  |> String::replace_all(old="\n", new=" ")
}
