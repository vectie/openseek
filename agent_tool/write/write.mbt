///|
/// Tool definition for `write`: overwrites `arguments.path` with
/// `arguments.content`.
pub fn definition() -> @agent_tool.AgentToolDefinition {
  AgentToolDefinition(
    "write",
    "Overwrite arguments.path with arguments.content.",
    JsonSchema({
      "type": "object",
      "properties": {
        "path": { "type": "string" },
        "content": { "type": "string" },
      },
      "required": ["path", "content"],
    }),
    Async(execute),
  )
}

///|
async fn execute(arguments : Json) -> @agent_tool.ToolResult {
  let (path, content) = match arguments {
    { "path": String(path), "content": String(content), .. } => (path, content)
    { "path": String(_), .. } =>
      return Continue("error: write requires arguments.content")
    Object(_) => return Continue("error: write requires arguments.path")
    _ => return Continue("error: write requires object arguments")
  }
  try {
    @fs.write_file(path, content, create_mode=CreateOrTruncate)
    Continue("ok: wrote \{content.length()} chars to \{path}")
  } catch {
    error => Continue("error writing \{path}: \{error}")
  }
}

///|
async test "write creates a file with the given content" {
  let path = "/tmp/openseek-write-test.txt"
  let result = execute({ "path": path, "content": "hello write" })
  guard result is Continue(output) else { fail("expected Continue") }
  assert_eq(output, "ok: wrote 11 chars to \{path}")
  let read_back = @fs.read_file(path).text()
  assert_eq(read_back, "hello write")
}

///|
async test "write rejects missing content" {
  let result = execute({ "path": "/tmp/openseek-noop.txt" })
  guard result is Continue(output) else { fail("expected Continue") }
  assert_eq(output, "error: write requires arguments.content")
}

///|
async test "write rejects missing path" {
  let result = execute({ "content": "stuff" })
  guard result is Continue(output) else { fail("expected Continue") }
  assert_eq(output, "error: write requires arguments.path")
}

///|
async test "write rejects non-object arguments" {
  let result = execute(Json::null())
  guard result is Continue(output) else { fail("expected Continue") }
  assert_eq(output, "error: write requires object arguments")
}
