package.cpath = package.cpath..";./build/luaclib/?.so"
package.path = package.path..";./lualib/?.lua"

local log = require "log"
log.init{log_basename = "simple_server",service_name = "simple server" }

local enet = require "enet"

local host = enet.host_create"localhost:5678"

while true do
	local event = host:service(100)
	if event then 
		if event.type == "receive" then
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