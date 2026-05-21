///|
/// The agent's local tool registry: the four functions the agent advertises to
/// DeepSeek (`shell`, `read`, `write`, `finish`) along with their JSON schemas
/// and executors. Raises if two definitions share a name.
fn tool_definitions() -> @agent_tool.Tools raise {
  Tools([
    AgentToolDefinition(
      "shell",
      "Run arguments.cmd through sh -c, optionally in arguments.cwd, and return exit code plus output.",
      JsonSchema({
        "type": "object",
        "properties": {
          "cmd": { "type": "string" },
          "cwd": { "type": "string" },
        },
        "required": ["cmd"],
      }),
      Async(execute_shell),
    ),
    AgentToolDefinition(
      "read",
      "Read arguments.path as text.",
      JsonSchema({
        "type": "object",
        "properties": { "path": { "type": "string" } },
        "required": ["path"],
      }),
      Async(execute_read),
    ),
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
      Async(execute_write),
    ),
    AgentToolDefinition(
      "finish",
      "End the task with arguments.answer.",
      JsonSchema({
        "type": "object",
        "properties": { "answer": { "type": "string" } },
        "required": ["answer"],
      }),
      Sync(execute_finish),
    ),
  ])
}

///|
test "function tools include json schemas" {
  let tools = tool_definitions()
  let function_tools = tools.function_tools()
  assert_eq(function_tools.length(), 4)
  let names = [ for t in function_tools => t.name ]
  assert_true(names.contains("shell"))
  assert_true(names.contains("read"))
  assert_true(names.contains("write"))
  assert_true(names.contains("finish"))
  for t in function_tools {
    let params = t.parameters.stringify()
    assert_true(params.contains("\"properties\""))
    assert_true(params.contains("\"required\""))
  }
}

///|
test "tool definitions are executable registry entries" {
  let tools = tool_definitions()
  guard tools.find("finish") is Some(tool) else { fail("missing finish tool") }
  guard tool.execute is Sync(execute) else {
    fail("finish should use a synchronous executor")
  }
  let result = execute({ "answer": "done" })
  guard result is Finish(answer) else { fail("finish should produce Finish") }
  assert_eq(answer, "done")
}
