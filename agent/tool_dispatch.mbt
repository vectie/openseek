///|
async fn execute_shell(arguments : Json) -> @agent_tool.ToolResult {
  match arguments {
    { "cmd": String(cmd), "cwd": String(cwd), .. } if cwd != "" =>
      @agent_tool.continue_result(
        shell(cmd, Some(cwd)) catch {
          error => "error running shell: \{error}"
        },
      )
    { "cmd": String(cmd), .. } =>
      @agent_tool.continue_result(
        shell(cmd, None) catch {
          error => "error running shell: \{error}"
        },
      )
    Object(_) =>
      @agent_tool.continue_result("error: shell requires arguments.cmd")
    _ => @agent_tool.continue_result("error: shell requires object arguments")
  }
}

///|
async fn execute_read(arguments : Json) -> @agent_tool.ToolResult {
  match arguments {
    { "path": String(path), .. } =>
      @agent_tool.continue_result(
        @fs.read_file(path).text() catch {
          error => "error reading \{path}: \{error}"
        },
      )
    Object(_) =>
      @agent_tool.continue_result("error: read requires arguments.path")
    _ => @agent_tool.continue_result("error: read requires object arguments")
  }
}

///|
async fn execute_write(arguments : Json) -> @agent_tool.ToolResult {
  let (path, content) = match arguments {
    { "path": String(path), "content": String(content), .. } => (path, content)
    { "path": String(_), .. } =>
      return @agent_tool.continue_result(
        "error: write requires arguments.content",
      )
    Object(_) =>
      return @agent_tool.continue_result("error: write requires arguments.path")
    _ =>
      return @agent_tool.continue_result(
        "error: write requires object arguments",
      )
  }
  try {
    @fs.write_file(path, content, create_mode=CreateOrTruncate)
    @agent_tool.continue_result(
      "ok: wrote \{content.length()} chars to \{path}",
    )
  } catch {
    error => @agent_tool.continue_result("error writing \{path}: \{error}")
  }
}

///|
fn execute_finish(arguments : Json) -> @agent_tool.ToolResult {
  let answer = match arguments {
    { "answer": String(answer), .. } => answer
    _ => ""
  }
  { output: answer, finished: true }
}

///|
async fn shell(cmd : String, cwd : String?) -> String {
  let (code, output) = match cwd {
    Some(cwd) => @process.collect_output_merged("sh", ["-c", cmd], cwd~)
    None => @process.collect_output_merged("sh", ["-c", cmd])
  }
  "exit=\{code}\n\{output.text()}"
}
