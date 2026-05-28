///|
async fn main {
  let config = cli_command().parse(env=@env.get_env_vars())
    |> config_from_matches
  let report = @harness.run_suite(config)
  println(report.markdown())
  if !report.passed() {
    fail(report.failure_message())
  }
}

///|
fn config_from_matches(matches : @argparse.Matches) -> @harness.Config raise {
  let runs = parse_positive_int(value(matches, "runs"), "--runs")
  let min_successes = parse_positive_int(
    value(matches, "min-successes"),
    "--min-successes",
  )
  guard min_successes <= runs else { fail("--min-successes must be <= --runs") }
  Config(
    api_key=value(matches, "api-key"),
    model=@deepseek.Model::parse(value(matches, "model")),
    runs~,
    min_successes~,
    max_steps=parse_positive_int(value(matches, "max-steps"), "--max-steps"),
    out_dir=value(matches, "out"),
    repo_root=value(matches, "repo-root"),
  )
}

///|
fn cli_command() -> @argparse.Command {
  Command(
    "file-edit-eval",
    about="Run statistical file-editing evals against the OpenSeek agent.",
    options=[
      OptionArg(
        "api-key",
        long="api-key",
        env="DEEPSEEK",
        required=true,
        about="DeepSeek API key.",
      ),
      OptionArg(
        "model",
        long="model",
        env="DEEPSEEK_MODEL",
        default_values=[@deepseek.V4Flash.to_string()],
        about="DeepSeek model: deepseek-v4-flash or deepseek-v4-pro.",
      ),
      OptionArg(
        "runs",
        long="runs",
        default_values=["10"],
        about="Number of trials. Cases repeat in order.",
      ),
      OptionArg(
        "min-successes",
        long="min-successes",
        default_values=["8"],
        about="Minimum successful trials required.",
      ),
      OptionArg(
        "max-steps",
        long="max-steps",
        default_values=["200"],
        about="Maximum agent steps per trial.",
      ),
      OptionArg(
        "out",
        long="out",
        default_values=[".moonagent/eval_runs/file_edit_flash"],
        about="Directory for workspaces, logs, and reports.",
      ),
      OptionArg(
        "repo-root",
        long="repo-root",
        default_values=["."],
        about="OpenSeek repository root used to run cmd/main.",
      ),
    ],
  )
}

///|
fn value(matches : @argparse.Matches, name : String) -> String raise {
  match matches.values.get(name) {
    Some([value]) => value
    Some(values) if values.length() > 0 => values[0]
    _ => fail("missing parsed argument: \{name}")
  }
}

///|
fn parse_positive_int(input : String, label : String) -> Int raise {
  let parsed = @string.parse_int(input) catch {
    _ => fail("\{label} must be a positive integer, got: \{input}")
  }
  guard parsed > 0 else {
    fail("\{label} must be a positive integer, got: \{input}")
  }
  parsed
}
