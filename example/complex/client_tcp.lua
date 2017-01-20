package.cpath = "./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"..";./build/lualib/?.lua"

local uv = require('luv')

local client = uv.new_tcp()
uv.tcp_connect(client, "127.0.0.1", 1337, function (err)
    assert(not err, err)
    uv.read_start(client, function (err, chunk)
      assert(not err, err)
      if chunk then
        print(chunk)
      else
        uv.close(client)
      end
    end)

    print('CTRL-C to break')
    while true do
        uv.write(client, "hello world")
        uv.sleep(1000)
    end
end)

uv.run('default')
uv.loop_close()
