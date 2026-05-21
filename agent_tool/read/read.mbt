///|
/// Tool definition for `read`: reads `arguments.path` as text and returns its
/// contents.
pub fn definition() -> @agent_tool.AgentToolDefinition {
  AgentToolDefinition(
    "read",
    "Read arguments.path as text.",
    JsonSchema({
      "type": "object",
      "properties": { "path": { "type": "string" } },
      "required": ["path"],
    }),
    Async(execute),
  )
}

///|
async fn execute(arguments : Json) -> @agent_tool.ToolResult {
  match arguments {
    { "path": String(path), .. } =>
      Continue(
        @fs.read_file(path).text() catch {
          error => "error reading \{path}: \{error}"
        },
      )
    Object(_) => Continue("error: read requires arguments.path")
    _ => Continue("error: read requires object arguments")
  }
}

///|
async test "read returns file contents" {
  let path = "/tmp/openseek-read-test.txt"
  @fs.write_file(path, "hello read", create_mode=CreateOrTruncate)
  let result = execute({ "path": path })
  guard result is Continue(output) else { fail("expected Continue") }
  assert_eq(output, "hello read")
}

///|
async test "read surfaces filesystem errors" {
  let result = execute({ "path": "/tmp/openseek-does-not-exist" })
  guard result is Continue(output) else { fail("expected Continue") }
  assert_true(output.contains("error reading"))
}

///|
async test "read rejects missing path" {
  let result = execute({})
  guard result is Continue(output) else { fail("expected Continue") }
  assert_eq(output, "error: read requires arguments.path")
}

///|
async test "read rejects non-object arguments" {
  let result = execute(Json::null())
  guard result is Continue(output) else { fail("expected Continue") }
  assert_eq(output, "error: read requires object arguments")
}
