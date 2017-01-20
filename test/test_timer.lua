package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua;./lualib/deps/?.lua"

local uv = require('luv')
local timer = require('timer')

local elapse = 0
local interval = timer.setInterval(1000, function ()
    elapse = elapse + 1000
    print("on_interval, elapse =", elapse)
end)

repeat
  --print("\ntick.")
until uv.run('once') == 0

print("done")

uv.walk(uv.close)
uv.run()
uv.loop_close()
