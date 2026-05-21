///|
/// Tool definition for `finish`: ends the agent loop with `arguments.answer`
/// as the final response.
pub fn definition() -> @agent_tool.AgentToolDefinition {
  AgentToolDefinition(
    "finish",
    "End the task with arguments.answer.",
    JsonSchema({
      "type": "object",
      "properties": { "answer": { "type": "string" } },
      "required": ["answer"],
    }),
    Sync(execute),
  )
}

///|
fn execute(arguments : Json) -> @agent_tool.ToolResult {
  let answer = match arguments {
    { "answer": String(answer), .. } => answer
    _ => ""
  }
  Finish(answer)
}

///|
test "finish returns Finish with the answer" {
  let result = execute({ "answer": "all done" })
  guard result is Finish(answer) else { fail("expected Finish") }
  assert_eq(answer, "all done")
}

///|
test "finish without answer returns empty Finish" {
  let result = execute({})
  guard result is Finish(answer) else { fail("expected Finish") }
  assert_eq(answer, "")
}

///|
test "finish ignores non-object arguments" {
  let result = execute(Json::null())
  guard result is Finish(answer) else { fail("expected Finish") }
  assert_eq(answer, "")
}
