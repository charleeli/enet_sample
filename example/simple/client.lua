package.cpath = "./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"..";./build/lualib/?.lua"

local pretty = require 'pl.pretty'
local enet = require "enet"
local log = require "log"
log.init{log_basename = "simple_client",service_name = "simple server" }

local SprotoLoader = require "sprotoloader"
local SprotoEnv = require "sproto_env"
SprotoEnv.init('./build/sproto')

local s2c_sp = SprotoLoader.load(SprotoEnv.PID_S2C)
local s2c_host = s2c_sp:host(SprotoEnv.BASE_PACKAGE)
local c2s_client = s2c_host:attach(SprotoLoader.load(SprotoEnv.PID_C2S))

local host = enet.host_create()
local server = host:connect("localhost:5678")

local session = 0

local function send_request(name, args)
    session = session + 1
    local v = c2s_client(name, args, session)
    --local size = #v + 4
    --local package = string.pack(">I2", size)..v..string.pack(">I4", session)
    server:send(v)
    --print_request(name, session,args)
end

local count = 0
while count < 100 do
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

	if count == 8 then
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
--log.exit()

