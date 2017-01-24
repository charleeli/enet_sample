package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path  = package.path..";./lualib/?.lua"..";./example/complex/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua"

local pretty = require 'pl.pretty'
local ls = require "lsocket"
local SprotoLoader = require "sprotoloader"
local SprotoEnv = require "sproto_env"
SprotoEnv.init('./build/sproto')

local s2c_sp = SprotoLoader.load(SprotoEnv.PID_S2C)
local s2c_host = s2c_sp:host(SprotoEnv.BASE_PACKAGE)
local c2s_client = s2c_host:attach(SprotoLoader.load(SprotoEnv.PID_C2S))

addr = '127.0.0.1'

port = 8858

client, err = ls.connect(addr, port)
if not client then
	print("error: "..err)
	os.exit(1)
end

local session = 0
local function send_request(name, args)
    session = session + 1
    local v = c2s_client(name, args, session)
    client:send(v)
end

local function check_cmd(s)
    if s == "" or s == nil then
        return s
    end

    local cmd = ""
    local args = nil
    local b, e = string.find(s, " ")
    if b then
        cmd = s:sub(0, b - 1)
        local args_data = "return " .. s:sub(e + 1)
        local f, err = load(args_data)
        if f == nil then
            print("illegal cmd", s, _args)
            return
        end

        local ok, _args = pcall(f)
        if (not ok) or (type(_args) ~= 'table') then
            print("illegal cmd", s, _args)
            return
        else
            args = _args
        end
    else
        cmd = s
    end

    local ok, err = pcall(send_request, cmd, args)
    if not ok then
        print('send err', cmd, args, err)
    end
end

-- wait for connect() to succeed or fail
ls.select(nil, {client})
ok, err = client:status()
if not ok then
	print("error: "..err)
	os.exit(1)
end

print "Socket info:"
for k, v in pairs(client:info()) do
	io.write(k..": "..tostring(v)..", ")
end
sock = client:info("socket")
print("\nSocket: "..sock.family.." "..sock.addr..":"..sock.port)
peer = client:info("peer")
print("Peer: "..peer.family.." "..peer.addr..":"..peer.port)

print("Type quit to quit.")
repeat
	io.write("Enter some text: ")
	s = io.read()
	check_cmd(s) -- send_private_chat {uuid=123,msg="hello"}

	ls.select({client})
	str, err = client:recv()
	if str then
		local type, session, response = s2c_host:dispatch(str)
        print('----',type, session)
        pretty.dump(response)
        print('----')
	elseif err then
		print("error: "..err)
	else
		print("server died, exiting")
		s = "quit"
	end
until s == "quit"

client:close()
