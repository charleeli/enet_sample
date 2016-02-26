package.cpath = package.cpath..";./build/luaclib/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"..";./build/lualib/?.lua"

local lfs = require"lfs"
local pretty = require 'pl.pretty'
local enet = require "enet"
local log = require "log"
log.init{log_basename = "simple_server",service_name = "simple server" }

local SprotoLoader = require "sprotoloader"
local SprotoEnv = require "sproto_env"
SprotoEnv.init('./build/sproto')

local c2s_sp = SprotoLoader.load(SprotoEnv.PID_C2S)
local c2s_host = c2s_sp:host(SprotoEnv.BASE_PACKAGE)

local request_handlers = {}

local function load_request_handlers()
    local path = './service'
    for file in lfs.dir(path) do
        local _,suffix = file:match "([^.]*).(.*)"
        if suffix == 'lua' then
            local module_data = setmetatable({}, { __index = _ENV })
            local routine, err = loadfile(path..'/'..file, "bt", module_data)
            assert(routine, err)()

            for k, v in pairs(module_data) do
                if type(v) == 'function' then
                    request_handlers[k] = v
                end
            end
        end
    end
end

load_request_handlers()

local host = enet.host_create"localhost:5678"

while true do
	local event = host:service(100)
	if event then 
		if event.type == "receive" then
			log.info("Got message: %s , %s",  event.data, event.peer)

			local type, name, request, response = c2s_host:dispatch(event.data)

			if not request_handlers[name] then
				log.error('request_handler %s not exist or not loaded',name)
			end

			local r = request_handlers[name](request)
			event.peer:send(response(r))
		elseif event.type == "connect" then
			log.info("Connect:%s", event.peer)
			--host:broadcast("new client connected")
		else
			log.info("Got event %s,%s", event.type, event.peer)
		end
	end
end

log.exit()