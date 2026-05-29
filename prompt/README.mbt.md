# OpenSeek Prompt

This package owns OpenSeek's built-in system prompt text and prompt-selection
policy. Prompt Markdown files are converted to generated MoonBit string
functions through the module-level `md_to_mbt_string` dev-build rule.

## Prompt Sources

- `base_prompt.md`: the default built-in prompt used by DeepSeek V4 Pro.
- `flash_prompt.md`: the built-in prompt tuned for DeepSeek V4 Flash.

## API Shape

- `base_system_prompt()`: return the base built-in prompt.
- `flash_system_prompt()`: return the Flash built-in prompt.
- `system_prompt_for_model(model, purpose?)`: select the prompt for a DeepSeek
  model. `purpose` currently supports `Coding` and `Review`; both route to the
  same model-specific prompt today, but the API keeps task-mode specialization
  out of the agent loop.
- `system_prompt(context)`: select with an explicit `PromptContext` when future
  factors outgrow the simple helper.

The agent package depends on this package for its default prompt, while the CLI
can still override or append prompt files for A/B experiments.
