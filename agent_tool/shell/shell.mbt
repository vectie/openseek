///|
/// Tool definition for `shell`: runs `arguments.cmd` through `sh -c`,
/// optionally in `arguments.cwd`, and returns the exit code and merged output.
pub fn definition() -> @agent_tool.AgentToolDefinition {
  AgentToolDefinition(
    "shell",
    "Run arguments.cmd through sh -c, optionally in arguments.cwd, and return exit code plus output.",
    JsonSchema({
      "type": "object",
      "properties": { "cmd": { "type": "string" }, "cwd": { "type": "string" } },
      "required": ["cmd"],
    }),
    Async(execute),
  )
}

///|
async fn execute(arguments : Json) -> @agent_tool.ToolResult {
  match arguments {
    { "cmd": String(cmd), "cwd": String(cwd), .. } if cwd != "" =>
      Continue(
        shell(cmd, Some(cwd)) catch {
          error => "error running shell: \{error}"
        },
      )
    { "cmd": String(cmd), .. } =>
      Continue(
        shell(cmd, None) catch {
          error => "error running shell: \{error}"
        },
      )
    Object(_) => Continue("error: shell requires arguments.cmd")
    _ => Continue("error: shell requires object arguments")
  }
}

///|
async fn shell(cmd : String, cwd : String?) -> String {
  let (code, output) = match cwd {
    Some(cwd) => @process.collect_output_merged("sh", ["-c", cmd], cwd~)
    None => @process.collect_output_merged("sh", ["-c", cmd])
  }
  "exit=\{code}\n\{output.text()}"
}

///|
async test "shell runs cmd and returns exit code plus output" {
  let result = execute({ "cmd": "echo hello" })
  guard result is Continue(output) else { fail("expected Continue") }
  assert_true(output.contains("exit=0"))
  assert_true(output.contains("hello"))
}

///|
async test "shell propagates non-zero exit codes" {
  let result = execute({ "cmd": "exit 7" })
  guard result is Continue(output) else { fail("expected Continue") }
  assert_true(output.contains("exit=7"))
}

///|
async test "shell rejects missing cmd" {
  let result = execute({ "cwd": "/tmp" })
  guard result is Continue(output) else { fail("expected Continue") }
  assert_eq(output, "error: shell requires arguments.cmd")
}

///|
async test "shell rejects non-object arguments" {
  let result = execute(Json::null())
  guard result is Continue(output) else { fail("expected Continue") }
  assert_eq(output, "error: shell requires object arguments")
}
