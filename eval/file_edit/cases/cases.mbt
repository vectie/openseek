///|
pub struct FileSpec {
  path : String
  content : String
}

///|
pub struct EvalCase {
  id : String
  instructions : String
  initial_files : Array[FileSpec]
  expected_files : Array[FileSpec]
  unchanged_files : Array[String]
  validation : Array[String]
}

///|
pub fn eval_cases() -> Array[EvalCase] {
  [
    exact_replace_case(),
    ambiguous_replace_case(),
    multiline_replace_case(),
    create_file_case(),
    compile_fix_case(),
  ]
}

///|
pub fn case_for_trial(index : Int) -> EvalCase {
  let cases = eval_cases()
  cases[index % cases.length()]
}

///|
pub fn EvalCase::task(self : EvalCase, workspace : String) -> String {
  (
    $|You are running a file-editing eval.
    $|
    $|Workspace: \{workspace}
    $|
    $|Rules:
    $|- Use read/edit/write for file changes.
    $|- Every file path passed to read/edit/write must be an absolute path under the Workspace.
    $|- Do not use shell, sed, perl, python, or redirection to modify files.
    $|- Preserve unrelated files exactly.
    $|- Re-read if an exact edit is ambiguous or stale.
    $|- Finish with the exact marker: file-edit-eval:\{self.id}
    $|
    $|Task:
    $|\{self.instructions}
  )
}

///|
fn exact_replace_case() -> EvalCase {
  {
    id: "exact_replace",
    instructions: "In src/note.txt, replace the unique word `beta` with `delta`. Leave every other byte unchanged.",
    initial_files: [
      { path: "src/note.txt", content: "alpha\nbeta\ngamma\n" },
      { path: "src/keep.txt", content: "do not touch\n" },
    ],
    expected_files: [{ path: "src/note.txt", content: "alpha\ndelta\ngamma\n" }],
    unchanged_files: ["src/keep.txt"],
    validation: [],
  }
}

///|
fn ambiguous_replace_case() -> EvalCase {
  {
    id: "ambiguous_replace",
    instructions: (
      #|In src/status.txt, change only the user-facing status line under `[user]`
      #|from `status = "todo"` to `status = "done"`. Leave the `[admin]`
      #|section unchanged.
    ),
    initial_files: [
      {
        path: "src/status.txt",
        content: (
          #|[user]
          #|name = "Ada"
          #|status = "todo"
          #|
          #|[admin]
          #|name = "Grace"
          #|status = "todo"
          #|
        ),
      },
      { path: "src/keep.txt", content: "unchanged\n" },
    ],
    expected_files: [
      {
        path: "src/status.txt",
        content: (
          #|[user]
          #|name = "Ada"
          #|status = "done"
          #|
          #|[admin]
          #|name = "Grace"
          #|status = "todo"
          #|
        ),
      },
    ],
    unchanged_files: ["src/keep.txt"],
    validation: [],
  }
}

///|
fn multiline_replace_case() -> EvalCase {
  {
    id: "multiline_replace",
    instructions: (
      #|In src/render.mbt, update `render_label` so it returns
      #|`"label: " + name.trim().to_owned()`. Preserve the helper function and
      #|the trailing newline exactly.
    ),
    initial_files: [
      {
        path: "src/render.mbt",
        content: (
          #|///|
          #|pub fn render_label(name : String) -> String {
          #|  "label: " + name
          #|}
          #|
          #|///|
          #|pub fn helper() -> String {
          #|  "helper"
          #|}
          #|
        ),
      },
      { path: "README.md", content: "render fixture\n" },
    ],
    expected_files: [
      {
        path: "src/render.mbt",
        content: (
          #|///|
          #|pub fn render_label(name : String) -> String {
          #|  "label: " + name.trim().to_owned()
          #|}
          #|
          #|///|
          #|pub fn helper() -> String {
          #|  "helper"
          #|}
          #|
        ),
      },
    ],
    unchanged_files: ["README.md"],
    validation: [],
  }
}

///|
fn create_file_case() -> EvalCase {
  {
    id: "create_file",
    instructions: (
      #|Create docs/summary.txt with exactly:
      #|
      #|OpenSeek file edit eval
      #|status: ready
      #|
      #|Do not change README.md.
    ),
    initial_files: [
      { path: "README.md", content: "existing docs\n" },
      { path: "docs/.keep", content: "" },
    ],
    expected_files: [
      {
        path: "docs/summary.txt",
        content: "OpenSeek file edit eval\nstatus: ready\n",
      },
    ],
    unchanged_files: ["README.md", "docs/.keep"],
    validation: [],
  }
}

///|
fn compile_fix_case() -> EvalCase {
  {
    id: "compile_fix",
    instructions: (
      #|This MoonBit workspace has one type error in lib.mbt. Fix the function
      #|so `moon check` passes. Use moon_cmd for validation after editing.
      #|Do not change moon.mod or moon.pkg.
    ),
    initial_files: [
      {
        path: "moon.mod",
        content: (
          #|name = "openseek/file_edit_fixture"
          #|
          #|version = "0.1.0"
          #|
          #|preferred_target = "native"
          #|
        ),
      },
      { path: "moon.pkg", content: "warnings = \"+unnecessary_annotation\"\n" },
      {
        path: "lib.mbt",
        content: (
          #|///|
          #|pub fn answer() -> Int {
          #|  "forty two"
          #|}
          #|
          #|///|
          #|test "answer" {
          #|  assert_eq(answer(), 42)
          #|}
          #|
        ),
      },
    ],
    expected_files: [
      {
        path: "lib.mbt",
        content: (
          #|///|
          #|pub fn answer() -> Int {
          #|  42
          #|}
          #|
          #|///|
          #|test "answer" {
          #|  assert_eq(answer(), 42)
          #|}
          #|
        ),
      },
    ],
    unchanged_files: ["moon.mod", "moon.pkg"],
    validation: ["moon", "check"],
  }
}
