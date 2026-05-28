///|
pub struct Config {
  api_key : String
  model : @deepseek.Model
  runs : Int
  min_successes : Int
  max_steps : Int
  out_dir : String
  repo_root : String
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
) -> Config {
  { api_key, model, runs, min_successes, max_steps, out_dir, repo_root }
}
