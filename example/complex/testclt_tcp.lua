package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path  = package.path..";./lualib/?.lua"..";./example/simple/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua"

local ls = require "lsocket"

addr = '127.0.0.1'

port = 1337

client, err = ls.connect(addr, port)
if not client then
	print("error: "..err)
	os.exit(1)
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
	ok, err = client:send(s)
	if not ok then print("error: "..err) end
	ls.select({client})
	str, err = client:recv()
	if str then
		print("reply: "..str)
	elseif err then
		print("error: "..err)
	else
		print("server died, exiting")
		s = "quit"
	end
until s == "quit"

client:close()
