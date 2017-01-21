package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path  = package.path..";./lualib/?.lua"..";./example/complex/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua"

local ls = require "lsocket"
local env = require"env"
local log = env.log
local request_handlers = env.request_handlers
local c2s_sp = env.c2s_sp
local c2s_host = env.c2s_host
local s2c_client = env.s2c_client

local server
local sockets = {}
local socketinfo = {}

local function add_socket(sock, ip, port)
    sockets[#sockets+1] = sock
    socketinfo[sock] = ip..":"..port
end

local function remove_socket(sock)
    local i, s
    for i, s in ipairs(sockets) do
        if s == sock then
            table.remove(sockets, i)
            socketinfo[sock] = nil
            return
        end
    end
end

local M = {count = 0}

function M.init(addr, port)
    server, err = ls.bind(addr, port, 10)
    if not server then
        print("error: "..err)
        os.exit(1)
    end

    print "Socket info:"
    for k, v in pairs(server:info()) do
        io.write(k..": "..tostring(v)..", ")
    end
    local sock = server:info("socket")
    print("\nSocket: "..sock.family.." "..sock.addr..":"..sock.port)

    sockets = {server}
end

function M.process()
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

         M.count = M.count + 1
    end
end

return M
