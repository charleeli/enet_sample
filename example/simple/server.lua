package.cpath = package.cpath..";./build/luaclib/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"..";./build/lualib/?.lua"

local pretty = require 'pl.pretty'
local enet = require "enet"
local log = require "log"
log.init{log_basename = "simple_server",service_name = "simple server" }

local SprotoLoader = require "sprotoloader"
local SprotoEnv = require "sproto_env"
SprotoEnv.init('./build/sproto')

local c2s_sp = SprotoLoader.load(SprotoEnv.PID_C2S)
local c2s_host = c2s_sp:host(SprotoEnv.BASE_PACKAGE)

local host = enet.host_create"localhost:5678"

while true do
	local event = host:service(100)
	if event then 
		if event.type == "receive" then
			local type, name, request, response = c2s_host:dispatch(event.data)
			print(type, name, request, response)
			pretty.dump(request)

			log.info("Got message: %s , %s",  event.data, event.peer)
			event.peer:send("howdy back at ya")
		elseif event.type == "connect" then
			log.info("Connect:%s", event.peer)
			host:broadcast("new client connected")
		else
			log.info("Got event %s,%s", event.type, event.peer)
		end
	end
end

log.exit()