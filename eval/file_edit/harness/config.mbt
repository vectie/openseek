///|
pub struct Config {
  api_key : String
  model : @deepseek.Model
  runs : Int
  min_successes : Int
  max_steps : Int
  out_dir : String
  repo_root : String
  prompt_label : String
  system_prompt_file : String
  system_prompt_addendum_file : String
}

///|
pub fn Config::Config(
  api_key~ : String,
  model~ : @deepseek.Model,
  runs~ : Int,
  min_successes~ : Int,
  max_steps~ : Int,
  out_dir~ : String,
  repo_root~ : String,
  prompt_label~ : String,
  system_prompt_file~ : String,
  system_prompt_addendum_file~ : String,
) -> Config {
  {
    api_key,
    model,
    runs,
    min_successes,
    max_steps,
    out_dir,
    repo_root,
    prompt_label,
    system_prompt_file,
    system_prompt_addendum_file,
  }
}
