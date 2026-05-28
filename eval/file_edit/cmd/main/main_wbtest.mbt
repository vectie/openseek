///|
test "cli defaults to flash baseline" {
  let matches = cli_command().parse(argv=["--api-key", "test-key"])
  let config = config_from_matches(matches)
  assert_eq(config.api_key, "test-key")
  assert_eq(config.model.to_string(), "deepseek-v4-flash")
  assert_eq(config.runs, 10)
  assert_eq(config.min_successes, 8)
  assert_eq(config.max_steps, 200)
}

///|
test "cli rejects impossible threshold" {
  let matches = cli_command().parse(argv=[
    "--api-key", "test-key", "--runs", "3", "--min-successes", "4",
  ])
  let _ = config_from_matches(matches) catch {
    error => {
      assert_true("\{error}".contains("--min-successes must be <= --runs"))
      return
    }
  }
  fail("impossible threshold parsed")
}
