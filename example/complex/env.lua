local share_env = require 'share_env'
local env = share_env.init()

env.request_handlers = {}
env.log = nil
env.sprotoloader = nil
env.sproto_env = nil
env.c2s_sp = nil
env.c2s_host = nil
env.s2c_client = nil

return share_env.fini(env)
