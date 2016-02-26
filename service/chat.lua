local log = require "log"
local JSON = require("JSON")

function send_private_chat(args)
    log.info("args = %s",JSON:encode_pretty(args))
    return {errcode = 0}
end

function send_world_chat(args)
    log.info("args = %s",JSON:encode(args))
    return {errcode = 0}
end