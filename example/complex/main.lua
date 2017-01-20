package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"..";./build/lualib/?.lua;./build/lualib/?.lua"

local ls = require "lsocket"
local lfs = require"lfs"
local Enet = require 'enet'
local log = require "log"
log.init{log_basename = "simple_server",service_name = "simple server" }

local SprotoLoader = require "sprotoloader"
local SprotoEnv = require "sproto_env"
SprotoEnv.init('./build/sproto')

local c2s_sp = SprotoLoader.load(SprotoEnv.PID_C2S)
local c2s_host = c2s_sp:host(SprotoEnv.BASE_PACKAGE)
local s2c_client = c2s_host:attach(SprotoLoader.load(SprotoEnv.PID_S2C))

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

local sockets = {}
local socketinfo = {}
function do_tcp_work(server)
    function add_socket(sock, ip, port)
        sockets[#sockets+1] = sock
        socketinfo[sock] = ip..":"..port
    end

    function remove_socket(sock)
        local i, s
        for i, s in ipairs(sockets) do
            if s == sock then
                table.remove(sockets, i)
                socketinfo[sock] = nil
                return
            end
        end
    end

    local ready = ls.select(sockets,0)
    if not ready then
        return
    end

    for _, s in ipairs(ready) do
        if s == server then
            local s1, ip, port = s:accept()
            print("Connection established from "..ip..", port "..port)
            add_socket(s1, ip, port)
        else
            i = socketinfo[s]
            local str, err = s:recv()
            if str ~= nil then
                str = string.gsub(str, "\n$", "")
                print("from "..i.." got '"..str.."', answering...")
                s:send("You sent: "..str.."\n")
            elseif err == nil then
                print("client "..i.." disconnected")
                s:close()
                remove_socket(s)
            else
                print("error: "..err)
            end
        end
    end
end

local function do_udp_work(host)
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

local function main()
    local tcp_server, err = ls.bind("127.0.0.1", 1337, 10)
    if not tcp_server then
        print("error: "..err)
        os.exit(1)
    end

    print "Socket info:"
    for k, v in pairs(tcp_server:info()) do
        io.write(k..": "..tostring(v)..", ")
    end

    local sock = tcp_server:info("socket")
    print("\nSocket: "..sock.family.." "..sock.addr..":"..sock.port)

    sockets = {tcp_server}

    local udp_server = Enet.host_create("127.0.0.1:5678")
    print("udp server booted")

    while true do
        do_udp_work(udp_server)
        do_tcp_work(tcp_server)
    end

end

main()
log.exit()
