package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path  = package.path..";./lualib/?.lua"..";./example/complex/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua"

local pretty = require 'pl.pretty'
local env = require "env"
local log = require "log"
local lfs = require "lfs"
local sprotoloader = require "sprotoloader"
local sproto_env = require "sproto_env"

local tcp_servlet
local enet_servlet

local function init_environment()
    env.log = log
    env.log.init{log_basename = "complex_server",service_name = "complex server" }
    env.sprotoloader = sprotoloader
    env.sproto_env = sproto_env
    env.sproto_env.init('./build/sproto')
    env.c2s_sp = env.sprotoloader.load(env.sproto_env.PID_C2S)
    env.c2s_host = env.c2s_sp:host(env.sproto_env.BASE_PACKAGE)
    env.s2c_client = env.c2s_host:attach(env.sprotoloader.load(env.sproto_env.PID_S2C))

    tcp_servlet = require'tcp_servlet'
    enet_servlet = require'enet_servlet'
end

local function init_request_handlers()
    local path = './service'
    for file in lfs.dir(path) do
        local _,suffix = file:match "([^.]*).(.*)"
        if suffix == 'lua' then
            local module_data = setmetatable({}, { __index = _ENV })
            local routine, err = loadfile(path..'/'..file, "bt", module_data)
            assert(routine, err)()

            for k, v in pairs(module_data) do
                if type(v) == 'function' then
                    env.request_handlers[k] = v
                end
            end
        end
    end
end

local function main()
    init_environment()
    init_request_handlers()

    tcp_servlet.init("127.0.0.1", 8858)
    enet_servlet.init("127.0.0.1", 5678)

    while true do
        tcp_servlet.handle()
        enet_servlet.handle()
    end
end

main()
log.info("complex server booted")
log.exit()
