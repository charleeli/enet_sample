package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path  = package.path..";./lualib/?.lua"..";./example/complex/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua"

local pretty = require 'pl.pretty'
local enet = require "enet"
local log = require "log"
log.init{log_basename = "complex_client",service_name = "complex server" }

local SprotoLoader = require "sprotoloader"
local SprotoEnv = require "sproto_env"
SprotoEnv.init('./build/sproto')

local s2c_sp = SprotoLoader.load(SprotoEnv.PID_S2C)
local s2c_host = s2c_sp:host(SprotoEnv.BASE_PACKAGE)
local c2s_client = s2c_host:attach(SprotoLoader.load(SprotoEnv.PID_C2S))

local host = enet.host_create()
local server = host:connect("127.0.0.1:5678")

local session = 0

local function send_request(name, args)
    session = session + 1
    local v = c2s_client(name, args, session)
    server:send(v)
end

local count = 0
while count < 1000 do
	local event = host:service(100)
	if event then
		if event.type == "receive" then
			log.info("Got message: %s",  event.data)

			local type, session, response = s2c_host:dispatch(event.data)

			print('----',type, session)
			pretty.dump(response)
			print('----')
		else
			log.info("Got event %s", event.type)
		end
	end

	if count % 8 == 0 then
		log.info("sending message")

		local ok, err = pcall(send_request, "send_private_chat", {uuid=123,msg="hello"})
		if not ok then
			print('send err', cmd, args, err)
		end
	end

	count = count + 1
end

server:disconnect()
host:flush()

log.info("done")
