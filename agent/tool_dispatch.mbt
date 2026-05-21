///|
async fn execute_shell(arguments : Json) -> @agent_tool.ToolResult {
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
async fn execute_read(arguments : Json) -> @agent_tool.ToolResult {
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
async fn execute_write(arguments : Json) -> @agent_tool.ToolResult {
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
fn execute_finish(arguments : Json) -> @agent_tool.ToolResult {
  let answer = match arguments {
    { "answer": String(answer), .. } => answer
    _ => ""
  }
  Finish(answer)
}

///|
async fn shell(cmd : String, cwd : String?) -> String {
  let (code, output) = match cwd {
    Some(cwd) => @process.collect_output_merged("sh", ["-c", cmd], cwd~)
    None => @process.collect_output_merged("sh", ["-c", cmd])
  }
  "exit=\{code}\n\{output.text()}"
}
