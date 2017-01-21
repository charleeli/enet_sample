package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path  = package.path..";./lualib/?.lua"..";./example/complex/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua"

local pretty = require 'pl.pretty'
local enet = require'enet'
local env = require"env"
local log = env.log
local request_handlers = env.request_handlers
local c2s_sp = env.c2s_sp
local c2s_host = env.c2s_host
local s2c_client = env.s2c_client

local host
local M = {}

function M.init(addr, port)
    host = enet.host_create(addr..':'..port)
    print("enet servlet booted")
end

function M.handle()
    local event = host:service(0)
    if event then
        if event.type == "receive" then
            log.info("Got message: %s , %s",  event.data, event.peer)

            local type, name, request, response = c2s_host:dispatch(event.data)
            print(type, name, request, response)
            if not request_handlers[name] then
                log.error('request_handler %s not exist or not loaded',name)
            end

            local r = request_handlers[name](request)
            event.peer:send(response(r))
        elseif event.type == "connect" then
            log.info("Connect:%s", event.peer)

            --host:broadcast("new client connected")
            host:broadcast(s2c_client("broadcast",{msg="new client connected"},0))
        else
            log.info("Got event %s,%s", event.type, event.peer)
        end
    end
end

return M
