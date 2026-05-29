///|
/// Intended use for the prompt selected for a model.
pub(all) enum PromptPurpose {
  Coding
  Review
} derive(Eq, Debug)

///|
/// Prompt-selection inputs.
pub struct PromptContext {
  model : @deepseek.Model
  purpose : PromptPurpose
} derive(Eq, Debug)

///|
/// Constructs prompt-selection inputs.
pub fn PromptContext::PromptContext(
  model~ : @deepseek.Model,
  purpose? : PromptPurpose = Coding,
) -> PromptContext {
  { model, purpose }
}

///|
/// Returns the base built-in system prompt.
pub fn base_system_prompt() -> String {
  base_prompt()
}

///|
/// Returns the DeepSeek V4 Flash built-in system prompt.
pub fn flash_system_prompt() -> String {
  flash_prompt()
}

///|
/// Selects a built-in system prompt for a prompt context.
pub fn system_prompt(context : PromptContext) -> String {
  match context.model {
    V4Flash => flash_system_prompt()
    V4Pro => base_system_prompt()
  }
}

///|
/// Selects a built-in system prompt for a model and optional purpose.
pub fn system_prompt_for_model(
  model : @deepseek.Model,
  purpose? : PromptPurpose = Coding,
) -> String {
  system_prompt(PromptContext(model~, purpose~))
}
