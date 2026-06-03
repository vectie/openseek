# Logger

This package provides a tiny native-only async logger for OpenSeek. It wraps an
`@stdio.Output`, applies a minimum severity level, and writes JSONL records.

## API Shape

- `Level`: `TRACE`, `DEBUG`, `INFO`, `WARN`, and `ERROR`.
- `stdout(min_level?)`: build a stdout logger.
- `Logger::at(level)`: get `Some(LogSink)` when `level` is enabled, otherwise
  `None`; use it directly with `<?` for filtered logging.
- `LogSink::write_object_begin()`, `LogSink::write_object_field(name, value)`,
  and `LogSink::write_object_end()`: the object-literal writer protocol used by
  `<+` and `<?`.

```mbt nocheck
///|
async fn log_step(logger : @logger.Logger, step : Int) -> Unit {
  logger.at(INFO) <? { "event": "agent_step", "step": step }
}
```

```moonbit check
///|
test "logger filters by severity" {
  let logger = @logger.Logger(@stdio.stdout, min_level=WARN)
  assert_true(logger.at(INFO) is None)
  assert_true(logger.at(DEBUG) is None)
  assert_true(logger.at(ERROR) is Some(_))
}
```
