///|
async test "optional sink supports object literal logging" {
  let logger = @logger.Logger(@stdio.stdout, min_level=ERROR)
  logger.at(INFO) <? { "event": "filtered", "step": 1, "is_error": false }
}
