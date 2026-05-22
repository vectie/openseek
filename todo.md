# OpenSeek Evaluation TODO

## DeepSeek V4 Pro TOML Parser Run

- Status: failed/incomplete as of 2026-05-22 11:17 CST.
- Task: use the OpenSeek agent with `deepseek-v4-pro` reasoning mode to create a MoonBit TOML parser plus CLI that dumps parsed TOML as JSON.
- Model setting: `DEEPSEEK_MODEL=deepseek-v4-pro`; OpenSeek defaults used reasoning mode with max reasoning effort.
- Log: `.moonagent/eval_runs/results/openseek_toml_cli_d4pro_reasoning.log`
- Log size: 2,283 lines / 99,169 bytes.
- Output workspace: `.moonagent/eval_runs/toml_cli_task`
- Result: the run stopped at step 60 with `=== max steps exhausted ===`.
- Validation: `moon check` in the generated workspace fails with 111 errors and 22 warnings.
- Missing deliverables: no CLI package, no README, no tests, no `moon info` output, and no passing `moon test`.

## DeepSeek V4 Pro TOML Parser Retry

- Status: stopped/incomplete as of 2026-05-22 12:35 CST after the run stalled at step 45.
- Task: same TOML parser plus JSON-dump CLI task, using `--max-steps 1000`.
- Log: `.moonagent/eval_runs/results/openseek_toml_cli_d4pro_reasoning_retry.log`
- Log size: 1,451 lines / 80,528 bytes.
- Output workspace: `.moonagent/eval_runs/toml_cli_task_retry`
- Result: log streaming worked; step output appeared immediately in `tee`.
- Progress: the retry scaffolded module, TOML package, and CLI package by step 2, then generated `types.mbt`, `scanner.mbt`, and `parser.mbt`.
- Validation: final manual `moon check` in the generated workspace fails with 59 errors and 12 warnings.
- Missing deliverables: no CLI source, no README, no tests, no `moon info` output, and no passing `moon test`.

## DeepSeek V4 Pro TOML Parser V3

- Status: succeeded as of 2026-05-22 15:16 CST.
- Task: same TOML parser plus JSON-dump CLI task, using `--max-steps 1000`.
- Log: `.moonagent/eval_runs/results/openseek_toml_cli_d4pro_reasoning_v3.log`
- Log size: 4,715 lines / 159,001 bytes.
- Output workspace: `.moonagent/eval_runs/toml_cli_task_v3`
- Result: the agent finished successfully at step 109 with parser package, native CLI package, README, public tests, whitebox tests, generated interface, and passing validation.
- Validation: independent `moon check` and `moon test` in the generated workspace passed with 32 tests.
- CLI smoke: `moon run --target native cmd/main -- /tmp/openseek-toml-v3-smoke.toml` produced `{"title":"Smoke","owner":{"name":"Moon","ports":[8000,8001]}}`.
- Performance improvement over earlier runs: the agent recovered from manifest and API mistakes, discovered current `Json` and async filesystem APIs before finalizing code, used `moon_check` repeatedly, and reached a clean parser package by the mid-run before adding CLI/tests/docs.
- Remaining issue: the README says `moon run cmd/main -- <file.toml>`, but the package is native-only and the module does not set `preferred_target = "native"`, so the documented command fails unless the user passes `--target native`.

## DeepSeek V4 Pro TOML Parser V4

- Status: succeeded as of 2026-05-22 19:49 CST after adding `moon_cmd`.
- Task: same TOML parser plus JSON-dump CLI task, using `--max-steps 1000`, with explicit instruction to use `moon_check` for compiler diagnostics and `moon_cmd` for tests, runs, info, fmt, and README command validation.
- Log: `.moonagent/eval_runs/results/openseek_toml_cli_d4pro_reasoning_v4.log`
- Log size: 6,477 lines / 277,636 bytes.
- Output workspace: `.moonagent/eval_runs/toml_cli_task_v4`
- Result: the agent finished successfully at step 135 with parser package, native CLI package, README, blackbox tests, whitebox tests, generated interface, and passing validation.
- Validation: independent `moon check` and `moon test` in the generated workspace passed with 22 tests.
- CLI smoke: `moon run --target native cmd/main -- test.toml` and stdin piping both produced valid JSON.
- `moon_cmd` impact: it caught real `moon test` failures, README doctest failures, native CLI compiler failures, and validated the final documented `moon run --target native` command. This directly fixed the V3 class of missed CLI-target mismatch.
- Remaining issue: the run took more steps and tokens than V3. The agent still wrote large parser files before the first meaningful check, read too much dependency source while discovering async APIs, and used `moon test --update` too freely.

## DeepSeek V4 Flash TOML Parser

- Status: failed/incomplete as of 2026-05-22 20:14 CST.
- Task: same TOML parser plus JSON-dump CLI task, using `--max-steps 1000`, `moon_check`, and `moon_cmd`.
- Model setting: `DEEPSEEK_MODEL=deepseek-v4-flash`.
- First attempt log: `.moonagent/eval_runs/results/openseek_toml_cli_d4flash_v1.log`
- First attempt size: 23 lines / 645 bytes.
- First attempt result: failed at step 1 by returning a JSON-like plan as assistant text instead of calling tools. No task files were created.
- Tool smoke log: `.moonagent/eval_runs/results/openseek_d4flash_tool_smoke.log`
- Tool smoke size: 9 lines / 270 bytes.
- Tool smoke result: succeeded; Flash called the shell tool for `pwd` and then finished, so the first attempt was prompt/tool-use sensitivity rather than complete tool inability.
- Second attempt log: `.moonagent/eval_runs/results/openseek_toml_cli_d4flash_v2.log`
- Second attempt size: 5,399 lines / 326,984 bytes.
- Output workspace: `.moonagent/eval_runs/toml_cli_task_flash_v2`
- Second attempt result: partially recovered, then failed. It reached a passing `moon check --output-json` at step 140 before writing tests, and a native CLI smoke run produced JSON for `key = "value"`. After it generated `toml_parser/toml_parser_test.mbt`, the workspace no longer checked.
- Final validation: independent `moon check --output-json` exits 255 with 117 errors and 48 warnings, dominated by invalid multiline string usage in tests. Independent `moon test --target native toml_parser` exits 1 with the same test syntax failures.
- Final run status: the transcript ends at step 147 with `OSError(@socket.Tcp::write(): Broken pipe)` after the failed test command; there is no `=== finished ===` success marker.
- Guardrail result: no `moon test --update` attempt was observed, so the snapshot-update guardrail did not trigger.
- Performance notes: Flash was fast enough to recover from the parser package's initial compile wall, but it relied on many one-off edits, got stuck on MoonBit syntax/API details for about 100 steps, and did not maintain validation after adding tests. It needs a stricter staged workflow before it is useful for this class of MoonBit task.

## Agent Performance Improvements To Investigate

- Done: stream logs per step through async stdio instead of relying on buffered `println`. During this run the log stayed at 0 bytes for several minutes, then flushed in large chunks, which made live supervision difficult.
- Add a task checklist inside the agent loop and force early coverage of required deliverables: package scaffold, minimal parser, CLI, README, tests, then richer TOML features.
- Run `moon check` after each generated file or small batch. The first check happened after several large files existed, so the agent had to triage 141 errors at once.
- Prefer replacing or deleting stale files when attempting a rewrite. The agent created `lexer2.mbt` but left the original broken `lexer.mbt` in the same package, so both compiled and errors compounded.
- Strengthen MoonBit syntax guidance for generated code: current error propagation syntax, method declarations, enum derives for equality, labeled parameters, suberror constructors, range loops, string APIs, and `Char?` handling.
- Parse `moon check --output-json` diagnostics and group root causes before editing. The raw compiler output was too large and led to scattered one-off edits.
- Add step-budget guardrails. If the CLI and tests do not exist by a threshold such as step 25, the agent should switch from feature expansion to a minimal compiling slice.
- Encourage an initial spike with tiny executable examples for unfamiliar APIs before writing large parser files.
- When an evaluation allows local references, surface nearby working examples such as `.moonagent/toml_parser_demo*` before implementing from scratch.
- Do not hide validation failures behind successful shell exits. In the retry, one check-like command returned `exit=0` while printing compiler failures, which led the loop to continue from a false success signal.
- Keep module/package manifests and dependency assumptions under validation. The retry repeatedly mis-modeled `@json.Json`, `String::split`, suberror constructor labels, and `@string`/`@strconv` parsing APIs.
- Done: add `moon_cmd` for direct `moon test`, `moon run`, `moon info`, `moon fmt`, and `moon build` validation without shell status masking.
- Done: add native CLI ergonomics checks in agent policy. V4 validated README commands with `moon_cmd` and explicit `--target native`.
- Done: add a `moon_cmd` guardrail against using `moon test --update` without `test_update_kind` and `test_update_reason`.
- Reduce token-heavy file reads during eval: prefer package docs, focused ranges, or summaries over dumping full dependency sources and generated files into the log.
- Teach the agent a staged validation invariant: after a package or test file is added, immediately rerun `moon check` before continuing, and treat a previously passing project as regressed until proven otherwise.
- Add prompt guidance for `#|...` multiline strings in MoonBit tests: bind them to local names or wrap them in parentheses before passing as function arguments.
