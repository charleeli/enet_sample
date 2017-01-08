local log = require "log"
local json = require "cjson"

function send_private_chat(args)
    log.info("args = %s",json.encode(args))
    return {errcode = 0}
end

function send_world_chat(args)
    log.info("args = %s",json.encode(args))
    return {errcode = 0}
end