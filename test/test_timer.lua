package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua"

local levent = require "levent.levent"
local timer = require 'timer'
local log = require "log"
log.init{log_basename = "test_timer",service_name = "test timer" }

local data = 'xxx'

local t = timer(levent, 1)

t:set_interval(3, function()
    print('set_interval',levent.now())
end)

function read_data(sec)
    while true do
        levent.sleep(sec)
        print("read_data:", data)
    end
end

function write_data(sec)
    while true do
        levent.sleep(sec)
        data = data .. '+'
        print("write_data:", data)
    end
end

function main()
    levent.spawn(read_data, 2)
    levent.spawn(write_data, 3)

    while true do
        levent.sleep(1)
        print("main")
    end
end

levent.start(main)

log.exit()

