///|
test "cli defaults to flash baseline" {
  let matches = cli_command().parse(argv=[], env={ "DEEPSEEK": "test-key" })
  let config = config_from_matches(matches)
  assert_eq(config.model.to_string(), "deepseek-v4-flash")
  assert_eq(config.runs, 10)
  assert_eq(config.min_successes, 8)
  assert_eq(config.max_steps, 200)
}

///|
test "cli rejects impossible threshold" {
  let matches = cli_command().parse(
    argv=["--runs", "3", "--min-successes", "4"],
    env={ "DEEPSEEK": "test-key" },
  )
  let _ = config_from_matches(matches) catch {
    error => {
      assert_true("\{error}".contains("--min-successes must be <= --runs"))
      return
    }
  }
  fail("impossible threshold parsed")
}
